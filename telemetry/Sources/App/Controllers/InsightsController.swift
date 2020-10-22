//
//  File.swift
//  
//
//  Created by Daniel Jilg on 18.10.20.
//

import Fluent
import Vapor
import FluentPostgresDriver

class InsightsController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let insights = routes.grouped(UserToken.authenticator())
        insights.get(":insightID", use: get)
        insights.post(use: create)
        insights.patch(":insightID", use: update)
        insights.delete(":insightID", use: delete)
    }
    
    func get(req: Request) throws -> EventLoopFuture<InsightDataTransferObject> {
        // TODO: Export this into a function
        guard let appIDString = req.parameters.get("appID"),
              let appID = UUID(appIDString),
              let insightIDString = req.parameters.get("insightID"),
              let insightID = UUID(insightIDString) else {
            throw Abort(.badRequest, reason: "Invalid parameter `appID`")
        }

        let user = try req.auth.require(User.self)
        // TODO: Only return apps for this user's org
        
        return Insight.query(on: req.db)
            .filter(\.$id == insightID)
            .first()
            .unwrap(or: Abort(.notFound))
            .flatMap { insight in
                
                let calculatedAtDate = Date()
                let earlierDate = Date(timeInterval: insight.rollingWindowSize, since: calculatedAtDate)
                let insightQuery = self.sqlQuery(for: insight, appID: appID, earlierDate: earlierDate, calculatedAtDate: calculatedAtDate)
                
                if let postgres = req.db as? PostgresDatabase {
                    
                    return postgres.simpleQuery(insightQuery)
                        .map { postgresRows in
                            
                            #if DEBUG
                            print(insight.title)
                            print(postgresRows)
                            #endif
                            
                            var aihsf: [[String: String]] = []
                            
                            for row in postgresRows {
                                var rowDictionary: [String: String] = [:]
                                
                                if let count = row.column("count")?.int {
                                    rowDictionary["count"] = "\(count)"
                                }
                                
                                if let breakdownKey = insight.breakdownKey, let breakdownKeyValue = row.column(breakdownKey.lowercased())?.string {
                                    rowDictionary[breakdownKey] = breakdownKeyValue
                                }
                                
                                if let day = row.column("day")?.string {
                                    rowDictionary["day"] = day
                                }
                                
                                aihsf.append(rowDictionary)
                            }
                            
                            let dto = InsightDataTransferObject(
                                id: insight.id!,
                                order: insight.order,
                                title: insight.title,
                                subtitle: insight.subtitle,
                                signalType: insight.signalType,
                                uniqueUser: insight.uniqueUser,
                                filters: insight.filters,
                                rollingWindowSize: insight.rollingWindowSize,
                                breakdownKey: insight.breakdownKey,
                                displayMode: insight.displayMode,
                                isExpanded: insight.isExpanded,
                                data: aihsf,
                                calculatedAt: Date()
                            )
                            
                            return dto
                        }
                } else { fatalError() }
            }
    }

    
    // SELECT json_agg(payload) as payload FROM signals WHERE app_id = '79167a27-ebbf-4012-9974-160624e5d07b' GROUP BY payload #>> '{platform}'
    // SELECT payload ->> 'platform' as platform FROM signals WHERE app_id = '79167a27-ebbf-4012-9974-160624e5d07b'
    // SELECT payload ->> 'systemVersion' as systemVersion, COUNT(*) FROM signals WHERE app_id = '79167a27-ebbf-4012-9974-160624e5d07b' GROUP BY systemVersion
    // SELECT DATE_TRUNC('day',received_at) AS day, COUNT(client_user) FROM signals WHERE app_id = '79167A27-EBBF-4012-9974-160624E5D07B' AND received_at > '2020-09-19T09:35:19Z' AND received_at < '2020-10-19T09:35:19Z' GROUP BY day ORDER BY day
    func sqlQuery(for insight: Insight, appID: UUID, earlierDate: Date, calculatedAtDate: Date) -> String {
        var selectClauses: String = ""
        var groupByClause: String? = nil
        var orderByClause: String? = nil
        var whereClauses: [String] = ["app_id = '\(appID.uuidString)'"]
        
        if let signalType = insight.signalType {
            whereClauses.append("signal_type = '\(signalType.escaped)'")
        }
        
        // Dates
        if insight.displayMode == .lineChart {
            whereClauses.append("received_at > '\(Formatter.iso8601noFS.string(from: Date(timeInterval: -3600*24*30, since: calculatedAtDate)))'")
            whereClauses.append("received_at < '\(Formatter.iso8601noFS.string(from: calculatedAtDate))'")
        } else {
            whereClauses.append("received_at > '\(Formatter.iso8601noFS.string(from: earlierDate))'")
            whereClauses.append("received_at < '\(Formatter.iso8601noFS.string(from: calculatedAtDate))'")
        }
        
        // Counting
        if insight.uniqueUser && insight.breakdownKey == nil {
            selectClauses = "COUNT(DISTINCT client_user)"
        }
        
        else if !insight.uniqueUser && insight.breakdownKey == nil {
            selectClauses = "COUNT(client_user)"
        }
        
        else if insight.uniqueUser, let breakdownkey = insight.breakdownKey {
            selectClauses = "payload ->> '\(breakdownkey.escaped)' as \(breakdownkey.escaped), COUNT(DISTINCT client_user)"
            groupByClause = "\(breakdownkey.escaped)"
        }
        
        else if !insight.uniqueUser, let breakdownkey = insight.breakdownKey {
            selectClauses = "payload ->> '\(breakdownkey.escaped)' as \(breakdownkey.escaped), COUNT(client_user)"
            groupByClause = "\(breakdownkey.escaped)"
        }
        
        if let breakdownKey = insight.breakdownKey {
            orderByClause = "count DESC"
        }
        
        // Historical Data
        let shouldCalculateHistoricalData = insight.displayMode == .lineChart && insight.breakdownKey == nil
        if shouldCalculateHistoricalData {
            let truncValue: String
            
            switch abs(insight.rollingWindowSize) {
            case 0...1:
                truncValue = "second"
            case 2...60:
                truncValue = "minute"
            case 61...3600:
                truncValue = "hour"
            case 3601...3600*24:
                truncValue = "day"
            case (3600*24)+1...3600*24*7:
                truncValue = "week"
            default:
                truncValue = "month"
            }
            
            selectClauses = "DATE_TRUNC('\(truncValue)',received_at) AS day, \(selectClauses)"
            groupByClause = "day"
            orderByClause = "day"
        }
        
        
        // Filters
        for filter in insight.filters {
            whereClauses.append("payload ->> '\(filter.key.escaped)' = '\(filter.value.escaped)'")
        }
        
        // Putting the band back together
        let clause = """
                    SELECT \(selectClauses)
                    FROM signals
                    WHERE \(whereClauses.joined(separator: " AND "))
                    \(groupByClause == nil ? "" : "GROUP BY " + groupByClause!)
                    \(orderByClause == nil ? "" : "ORDER BY " + orderByClause!)
                    ;
                    """
        print(clause)
        return clause
    }
    
    func create(req: Request) throws -> EventLoopFuture<Insight> {
        guard let insightGroupIDString = req.parameters.get("insightGroupID"),
              let insightGroupID = UUID(insightGroupIDString) else {
            throw Abort(.badRequest, reason: "Invalid parameter `insightGroupID`")
        }
        
        let user = try req.auth.require(User.self)
        let insightCreateRequestBody = try req.content.decode(InsightCreateRequestBody.self)
        
        let insight = Insight()
        insight.$group.id = insightGroupID
        insight.order = insightCreateRequestBody.order
        insight.title = insightCreateRequestBody.title
        insight.subtitle = insightCreateRequestBody.subtitle
        insight.signalType = insightCreateRequestBody.signalType
        insight.uniqueUser = insightCreateRequestBody.uniqueUser
        insight.filters = insightCreateRequestBody.filters
        insight.rollingWindowSize = insightCreateRequestBody.rollingWindowSize
        insight.breakdownKey = insightCreateRequestBody.breakdownKey
        insight.displayMode = insightCreateRequestBody.displayMode
        insight.isExpanded = insightCreateRequestBody.isExpanded
        
        return insight.save(on: req.db).map { insight }
    }
    
    func update(req: Request) throws -> EventLoopFuture<InsightDataTransferObject> {
        // TODO: Export this into a function
        guard let appIDString = req.parameters.get("appID"),
              let appID = UUID(appIDString),
              let insightIDString = req.parameters.get("insightID"),
              let insightID = UUID(insightIDString) else {
            throw Abort(.badRequest, reason: "Invalid parameter `appID`")
        }
        
        let insightUpdateRequestBody = try req.content.decode(InsightUpdateRequestBody.self)
        
        let user = try req.auth.require(User.self)

        
        return Insight.query(on: req.db)
            .filter(\.$id == insightID)
            .first()
            .unwrap(or: Abort(.notFound))
            .flatMap { insight in
                insight.$group.id = insightUpdateRequestBody.groupID
                insight.order = insightUpdateRequestBody.order
                insight.title = insightUpdateRequestBody.title
                insight.subtitle = insightUpdateRequestBody.subtitle
                insight.signalType = insightUpdateRequestBody.signalType
                insight.uniqueUser = insightUpdateRequestBody.uniqueUser
                insight.filters = insightUpdateRequestBody.filters
                insight.rollingWindowSize = insightUpdateRequestBody.rollingWindowSize
                insight.breakdownKey = insightUpdateRequestBody.breakdownKey
                insight.displayMode = insightUpdateRequestBody.displayMode
                insight.isExpanded = insightUpdateRequestBody.isExpanded
                
                return insight.update(on: req.db)
            }
            .flatMap { try! self.get(req: req) }
    }
    
    func delete(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        guard let insightIDString = req.parameters.get("insightID"),
              let insightID = UUID(insightIDString) else {
            throw Abort(.badRequest, reason: "Invalid parameter `insightID`")
        }
        
        let user = try req.auth.require(User.self)
        
        // TODO: Filter by user org
        return Insight.query(on: req.db)
            .filter(\.$id == insightID)
            .first()
            .unwrap(or: Abort(.notFound))
            .flatMap { $0.delete(on: req.db) }
            .map { .ok }
    }
}
