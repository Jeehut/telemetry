//
//  File.swift
//  
//
//  Created by Daniel Jilg on 18.10.20.
//

import Fluent
import Vapor

class InsightsController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let insights = routes.grouped(UserToken.authenticator())
        insights.get(":insightID", use: get)
//        insights.get(":insightID", "historicaldata", use: getHistoricalData)
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
//            .with(\.$historicalData)
            .first()
            .unwrap(or: Abort(.notFound))
            .flatMap { insight in
                                
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
                    data: [:],
                    calculatedAt: Date()
                )
                
                return req.eventLoop.makeSucceededFuture(dto)
            }
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
