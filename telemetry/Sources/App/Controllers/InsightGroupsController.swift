//
//  File.swift
//  
//
//  Created by Daniel Jilg on 28.09.20.
//

import Fluent
import Vapor

class InsightGroupsController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let insightGroups = routes.grouped(UserToken.authenticator())
        insightGroups.get(use: list)
        insightGroups.post(use: create)
        insightGroups.delete(":insightGroupID", use: delete)
    }
    
    func list(req: Request) throws -> EventLoopFuture<[InsightGroup]> {
        guard let appIDString = req.parameters.get("appID"),
              let appID = UUID(appIDString) else {
            throw Abort(.badRequest, reason: "Invalid parameter `appID`")
        }
        
        let user = try req.auth.require(User.self)
        // TODO: Only return apps for this user's org
        
        return InsightGroup.query(on: req.db)
            .with(\.$insights)
            .filter(\.$app.$id == appID)
            .all()
    }
    
    func create(req: Request) throws -> EventLoopFuture<InsightGroup> {
        struct InsightGroupCreateRequestBody: Content, Validatable {
            let title: String
            
            static func validations(_ validations: inout Validations) {
                validations.add("title", as: String.self, is: !.empty)
            }
        }
        
        guard let appIDString = req.parameters.get("appID"),
              let appID = UUID(appIDString) else {
            throw Abort(.badRequest, reason: "Invalid parameter `appID`")
        }
        
        let user = try req.auth.require(User.self)
        let insightGroupCreateRequestBody = try req.content.decode(InsightGroupCreateRequestBody.self)
        
        let insightGroup = InsightGroup()
        insightGroup.title = insightGroupCreateRequestBody.title
        insightGroup.$app.id = appID
        
        return insightGroup.save(on: req.db).map { insightGroup }
    }
    
    func delete(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        guard let insightGroupIDString = req.parameters.get("insightGroupID"),
              let insightGroupID = UUID(insightGroupIDString) else {
            throw Abort(.badRequest, reason: "Invalid parameter `insightGroupID`")
        }
        
        let user = try req.auth.require(User.self)
        
        // TODO: Filter by user org
        return InsightGroup.query(on: req.db)
            .filter(\.$id == insightGroupID)
            .first()
            .unwrap(or: Abort(.notFound))
            .flatMap { $0.delete(on: req.db) }
            .map { .ok }
    }
}