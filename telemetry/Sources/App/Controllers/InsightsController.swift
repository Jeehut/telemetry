//
//  File.swift
//  
//
//  Created by Daniel Jilg on 28.09.20.
//

import Fluent
import Vapor

class InsightsController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let insights = routes.grouped(UserToken.authenticator())
        insights.get(":insightID", use: get)
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
                switch insight.insightType {
                case .breakdown:
                    return self.getBreakdown(insight: insight, req: req, appID: appID)
                case .count:
                    return self.getCount(insight: insight, req: req, appID: appID)
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

