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
                let insightQuery = insight.breakdownKey == nil
                    ? self.timeSeriesSQLQuery(for: insight, appID: appID, earlierDate: earlierDate, calculatedAtDate: calculatedAtDate)
                    : self.breakDownSQLQuery(for: insight, appID: appID, earlierDate: earlierDate, calculatedAtDate: calculatedAtDate)
                
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
                                
                                if let yAxisValue = row.column("yaxisvalue")?.int {
                                    rowDictionary["yAxisValue"] = "\(yAxisValue)"
                                }
                                
                                if let breakdownKey = insight.breakdownKey, let breakdownKeyValue = row.column(breakdownKey.lowercased())?.string {
                                    rowDictionary[breakdownKey] = breakdownKeyValue
                                }
                                
                                if let xAxisValue = row.column("xaxisvalue")?.string {
                                    rowDictionary["xAxisValue"] = xAxisValue
                                } else {
                                    rowDictionary["xAxisValue"] = "<None>"
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
                                groupBy: insight.groupBy,
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

    

    func breakDownSQLQuery(for insight: Insight, appID: UUID, earlierDate: Date, calculatedAtDate: Date) -> String {
        var selectClauses: String = ""
        var groupByClause: String
        let orderByClause: String = "yAxisValue DESC"
        var whereClauses: [String] = ["app_id = '\(appID.uuidString)'"]
        let breakdownkey = insight.breakdownKey!
        
        if let signalType = insight.signalType {
            whereClauses.append("signal_type = '\(signalType.escaped)'")
        }
        
        // Dates
        whereClauses.append("received_at > '\(Formatter.iso8601noFS.string(from: earlierDate))'")
        whereClauses.append("received_at < '\(Formatter.iso8601noFS.string(from: calculatedAtDate))'")
        
        // Counting
        if insight.uniqueUser {
            selectClauses = "payload ->> '\(breakdownkey.escaped)' as xAxisValue, COUNT(DISTINCT client_user) as yAxisValue"
            groupByClause = "xAxisValue"
        }
        
        else {
            selectClauses = "payload ->> '\(breakdownkey.escaped)' as xAxisValue, COUNT(client_user) as yAxisValue"
            groupByClause = "xAxisValue"
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
                    GROUP BY \(groupByClause)
                    ORDER BY \(orderByClause)
                    ;
                    """
        #if DEBUG
        print(clause)
        #endif
        
        return clause
    }
    
    func timeSeriesSQLQuery(for insight: Insight, appID: UUID, earlierDate: Date, calculatedAtDate: Date) -> String {
        var selectClauses: String = ""
        var groupByClause: String = ""
        var orderByClause: String = ""
        var whereClauses: [String] = ["app_id = '\(appID.uuidString)'"]
        
        if let signalType = insight.signalType {
            whereClauses.append("signal_type = '\(signalType.escaped)'")
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
        
        // Historical Data
        if let truncValue = insight.groupBy?.rawValue {
            selectClauses = "DATE_TRUNC('\(truncValue)',received_at) AS day, \(selectClauses)"
            groupByClause = "day"
            orderByClause = "day"
        }
        
        // Filters
        for filter in insight.filters {
            whereClauses.append("payload ->> '\(filter.key.escaped)' = '\(filter.value.escaped)'")
        }
        
        let groupByValue = insight.groupBy?.rawValue ?? "day"
        
        let countValue = insight.uniqueUser ? "DISTINCT user" : "*"
        
        let clause = """
        WITH
        time_range AS (
          SELECT generate_series(date_trunc('\(groupByValue)', '\(Formatter.iso8601noFS.string(from: earlierDate))'::date), date_trunc('\(groupByValue)', '\(Formatter.iso8601noFS.string(from: calculatedAtDate))'::date), '1 \(groupByValue)'::interval) as xAxisValue
        ),

        counts AS (
          SELECT date_trunc('\(groupByValue)', received_at) as xAxisValue,
                 count(\(countValue)) as count
          FROM signals
          WHERE \(whereClauses.joined(separator: " AND "))
          GROUP BY 1
        )

        SELECT trim(both '"' from to_json(time_range.xAxisValue)::text) as xAxisValue,
               counts.count as yAxisValue
        FROM time_range
        LEFT OUTER JOIN counts on time_range.xAxisValue = counts.xAxisValue
        ORDER BY time_range.xAxisValue;
        """
        #if DEBUG
        print(clause)
        #endif
        
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
        insight.groupBy = insightCreateRequestBody.groupBy
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
                insight.groupBy = insightUpdateRequestBody.groupBy
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
