//
//  File.swift
//  
//
//  Created by Daniel Jilg on 28.09.20.
//

import Fluent
import Vapor

enum InsightFilterCondition: Equatable {
    case uniqueUser
    case keywordEquals(keyword: String, targetValue: String)
}

class InsightsController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let insights = routes.grouped(UserToken.authenticator())
        insights.get(":insightID", use: get)
        insights.get(":insightID", "historicaldata", use: getHistoricalData)
        insights.post(use: create)
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
                // Parse Conditions
                let conditions = self.parseConditions(from: insight.configuration["conditions"])
                
                // Route to Calculation Method
                switch insight.insightType {
                case .breakdown:
                    return self.getBreakdown(insight: insight, conditions: conditions, req: req, appID: appID)
                case .count:
                    return self.getCount(insight: insight, conditions: conditions, req: req, appID: appID)
                default:
                    let dto = InsightDataTransferObject(
                        id: insight.id!,
                        title: insight.title,
                        insightType: insight.insightType,
                        timeInterval: insight.timeInterval,
                        configuration: insight.configuration,
                        data: ["unknown type": 0],
                        calculatedAt: Date())
                    
                    return req.eventLoop.makeSucceededFuture(dto)
                }
            }
    }
    
    func getHistoricalData(req: Request) throws -> EventLoopFuture<[InsightHistoricalData]> {
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
            .with(\.$historicalData)
            .first()
            .unwrap(or: Abort(.notFound))
            .flatMap { insight in
                let furthestBack = Date(timeIntervalSinceNow: -3600*24*35) // Slightly over a month ago
                var currentDate = Date()
                
                // Calculate Historical Data
                while currentDate > furthestBack {
                    // Calculate the canonical start of day for the previous day
                    currentDate = Calendar.current.startOfDay(for: Date(timeInterval: -1, since: currentDate))
                    
                    // Check if there's a UserCount calculated at currentDate
                    guard insight.historicalData.filter({ historicalData in return historicalData.calculatedAt == currentDate }).isEmpty else {
                        continue
                    }
                    
                    // If not, create and save it
                    
                    // Parse Conditions
                    let conditions = self.parseConditions(from: insight.configuration["conditions"])
                    
                    // Route to Calculation Method
                    var insightDTOFuture: EventLoopFuture<InsightDataTransferObject>? = nil
                    switch insight.insightType {
                    case .breakdown:
                        insightDTOFuture = self.getBreakdown(insight: insight, conditions: conditions, calculatedAtDate: currentDate, req: req, appID: appID)
                    case .count:
                        insightDTOFuture = self.getCount(insight: insight, conditions: conditions, calculatedAtDate: currentDate,  req: req, appID: appID)
                    default:
                        break
                    }
                    
                    _ = insightDTOFuture?.map { insightDTO in
                        let insightHistoricalData = InsightHistoricalData()
                        insightHistoricalData.calculatedAt = insightDTO.calculatedAt
                        insightHistoricalData.data = insightDTO.data
                        insightHistoricalData.$insight.id = insightDTO.id
                        _ = insightHistoricalData.save(on: req.db)
                    }
                }
                
                return InsightHistoricalData.query(on: req.db)
                    .filter(\.$insight.$id == insightID)
                    .filter(\.$calculatedAt > furthestBack)
                    .sort(\.$calculatedAt, .ascending)
                    .all()
            }
    }
    
    func parseConditions(from conditions: String?) -> [InsightFilterCondition] {
        var returnConditions: [InsightFilterCondition] = []
        
        guard let conditions = conditions else { return returnConditions }
                
        for fragment in conditions.split(separator: ";") {
            let cleanedFragment = fragment.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            
            if cleanedFragment == "unique-user" {
                returnConditions.append(.uniqueUser)
            }
            
            else if cleanedFragment.contains("==") {
                let fragmentParts = cleanedFragment.split(separator: "=")
                guard let payloadKey = fragmentParts.first else { continue }
                guard let payloadValue = fragmentParts.last else { continue }
                returnConditions.append(.keywordEquals(keyword: String(payloadKey), targetValue: String(payloadValue)))
            }
            
            else {
                print("Unknown Fragment, \(cleanedFragment) Skipping.")
            }
            
        }
        
        return returnConditions
    }
    
    func create(req: Request) throws -> EventLoopFuture<Insight> {
        struct InsightCreateRequestBody: Content, Validatable {
            let title: String
            let insightType: Insight.InsightType
            let timeInterval: TimeInterval
            let configuration: [String: String]
            
            static func validations(_ validations: inout Validations) {
                // TOOD: More validations
                validations.add("title", as: String.self, is: !.empty)
            }
        }
        
        guard let insightGroupIDString = req.parameters.get("insightGroupID"),
              let insightGroupID = UUID(insightGroupIDString) else {
            throw Abort(.badRequest, reason: "Invalid parameter `insightGroupID`")
        }
        
        let user = try req.auth.require(User.self)
        let insightCreateRequestBody = try req.content.decode(InsightCreateRequestBody.self)
        
        let insight = Insight()
        insight.$group.id = insightGroupID
        insight.title = insightCreateRequestBody.title
        insight.insightType = insightCreateRequestBody.insightType
        insight.timeInterval = insightCreateRequestBody.timeInterval
        insight.configuration = insightCreateRequestBody.configuration
        
        return insight.save(on: req.db).map { insight }
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

