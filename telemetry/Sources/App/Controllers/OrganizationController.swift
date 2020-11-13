//
//  File.swift
//  
//
//  Created by Daniel Jilg on 11.11.20.
//

import Vapor
import Fluent

struct OrganizationController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let organization = routes.grouped(UserToken.authenticator())
        organization.get("users", use: getUsers)
        organization.get("joinRequests", use: getJoinRequests)
        organization.post("joinRequests", use: createJoinRequest)
        organization.delete("joinRequests", ":joinRequestID", use: deleteJoinRequest)
        
        // No auth checking
        routes.post("joinRequests", "join", use: join)
    }
    
    // List all users belonging to this organization
    func getUsers(req: Request) throws -> EventLoopFuture<[UserDataTransferObject]> {
        let user = try req.auth.require(User.self)
        return User.query(on: req.db)
            .filter(\.$organization.$id == user.$organization.id)
            .all()
            .map { orgUserList in
                orgUserList.map { UserDataTransferObject(user: $0) }
            }
    }
    
    
    // List all OrganizationJoinRequests belonging to this organization
    func getJoinRequests(req: Request) throws -> EventLoopFuture<[OrganizationJoinRequest]> {
        let user = try req.auth.require(User.self)
        
        return OrganizationJoinRequest.query(on: req.db)
                .filter(\.$organization.$id == user.$organization.id)
                .all()
    }
    
    // Create a new Join Request
    func createJoinRequest(req: Request) throws -> EventLoopFuture<OrganizationJoinRequest> {
        let user = try req.auth.require(User.self)
        
        let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let newTokenValue = String((0..<32).map{ _ in letters.randomElement()! })
        
        let organizationJoinRequest = OrganizationJoinRequest()
        organizationJoinRequest.$organization.id = user.$organization.id
        organizationJoinRequest.registrationToken = newTokenValue
        
        return organizationJoinRequest.save(on: req.db)
            .map { organizationJoinRequest }
    }
    
    // Delete a Join Request
    func deleteJoinRequest(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        guard let joinRequestIDString = req.parameters.get("joinRequestID"),
              let joinRequestID = UUID(joinRequestIDString) else {
            throw Abort(.badRequest, reason: "Invalid parameter `joinRequestID`")
        }
        
        let user = try req.auth.require(User.self)
        
        return OrganizationJoinRequest.query(on: req.db)
            .filter(\.$organization.$id == user.$organization.id)
            .filter(\.$id == joinRequestID)
            .first()
            .unwrap(or: Abort(.notFound))
            .flatMap { $0.delete(on: req.db) }
            .map { .ok }
    }
    
    struct OrganizationJoinRequestURLObject: Content {
        var email: String
        var firstName: String
        var lastName: String
        var password: String
        let organizationID: UUID
        let organizationName: String
        let registrationToken: String
    }
    
    // Join an Organization
    func join(req: Request) throws -> EventLoopFuture<UserDataTransferObject> {
        let orgJoinRequest = try req.content.decode(OrganizationJoinRequestURLObject.self)
        
        return OrganizationJoinRequest.query(on: req.db)
            .filter(\.$organization.$id == orgJoinRequest.organizationID)
            .filter(\.$registrationToken == orgJoinRequest.registrationToken)
            .first()
            .unwrap(or: Abort(.notFound))
            .flatMap { $0.delete(on: req.db) }
            .flatMap {
                let hashedPassword = UsersController.hash(from: orgJoinRequest.password)
                
                let user = User(
                    firstName: orgJoinRequest.firstName,
                    lastName: orgJoinRequest.lastName,
                    isFoundingUser: false,
                    email: orgJoinRequest.email,
                    passwordHash: hashedPassword,
                    organizationID: orgJoinRequest.organizationID
                )
                
                return user.create(on: req.db).map { UserDataTransferObject(user: user) }
            }
    }
}
