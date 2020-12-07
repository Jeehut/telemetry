import Fluent
import Vapor
import Mailgun

class BetaRequestEmailsController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let betarequests = routes.grouped(UserToken.authenticator())
        betarequests.get(use: list)
        betarequests.post(use: create)
        betarequests.post(":betaRequestEmailID", "send_email", use: sendEmail)
        betarequests.patch(":betaRequestEmailID", use: update)
        betarequests.delete(":betaRequestEmailID", use: delete)
    }
    
    func list(req: Request) throws -> EventLoopFuture<[BetaRequestEmail]> {
        let user = try req.auth.require(User.self)
        return user.$organization.load(on: req.db).flatMapThrowing {
            if !user.organization.isSuperOrg {
                throw Abort(.unauthorized, reason: "Not a super org!")
            }
        }.flatMap {
            BetaRequestEmail.query(on: req.db)
                .sort(\.$requestedAt, .ascending)
                .all()
        }
    }

    func create(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        struct EmailRequestBody: Content, Validatable {
            let email: String

            static func validations(_ validations: inout Validations) {
                validations.add("email", as: String.self, is: !.empty)
            }
        }

        let emailRequestBody = try req.content.decode(EmailRequestBody.self)
        
        let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let newTokenValue = String((0..<8).map{ _ in letters.randomElement()! })
        
        let betaRequestEmail = BetaRequestEmail()
        betaRequestEmail.email = emailRequestBody.email
        betaRequestEmail.requestedAt = Date()
        betaRequestEmail.isFulfilled = false
        betaRequestEmail.registrationToken = newTokenValue
        
        return betaRequestEmail.save(on: req.db)
            .map { HTTPStatus.ok }
    }
    
    
    func sendEmail(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        guard let betaRequestEmailIDString = req.parameters.get("betaRequestEmailID"),
              let betaRequestEmailID = UUID(betaRequestEmailIDString) else {
            throw Abort(.badRequest, reason: "Invalid parameter `betaRequestEmailID`")
        }
        
        let user = try req.auth.require(User.self)
        
        return user.$organization.load(on: req.db).flatMapThrowing {
            if !user.organization.isSuperOrg {
                throw Abort(.unauthorized, reason: "Not a super org!")
            }
        }.flatMap {
            BetaRequestEmail.query(on: req.db)
                .filter(\.$id == betaRequestEmailID)
                .first()
                .unwrap(or: Abort(.notFound))
                .flatMap { betaRequest in
                    betaRequest.sentAt = Date()
                    
                    let message = MailgunTemplateMessage(
                        from: "daniel@gmail.com",
                        to: betaRequest.email,
                        subject: "Beta Access to Telemetry, Analytics that's Not Evil",
                        template: "beta-request-email",
                        templateData: ["registration_code": betaRequest.registrationToken]
                    )

                    return req.mailgun().send(message).flatMap { _ in
                        betaRequest.save(on: req.db)
                            .map {
                                HTTPStatus.ok
                            }
                    }
                }
        }
        
    }
    
    func update(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        struct BetaRequestUpdateBody: Content {
            let sentAt: Date?
            let isFulfilled: Bool
        }
        
        guard let betaRequestEmailIDString = req.parameters.get("betaRequestEmailID"),
              let betaRequestEmailID = UUID(betaRequestEmailIDString) else {
            throw Abort(.badRequest, reason: "Invalid parameter `betaRequestEmailID`")
        }
        
        let user = try req.auth.require(User.self)
        
        let betaRequestUpdateBody = try req.content.decode(BetaRequestUpdateBody.self)
        
        return user.$organization.load(on: req.db).flatMapThrowing {
            if !user.organization.isSuperOrg {
                throw Abort(.unauthorized, reason: "Not a super org!")
            }
        }.flatMap {
            BetaRequestEmail.query(on: req.db)
                .filter(\.$id == betaRequestEmailID)
                .first()
                .unwrap(or: Abort(.notFound))
                .flatMap { betaRequest in
                    betaRequest.sentAt = betaRequestUpdateBody.sentAt
                    betaRequest.isFulfilled = betaRequestUpdateBody.isFulfilled
                    return betaRequest.save(on: req.db)
                        .map {
                            HTTPStatus.ok
                        }
                }
        }
        
    }
    
    func delete(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        guard let betaRequestEmailIDString = req.parameters.get("betaRequestEmailID"),
              let betaRequestEmailID = UUID(betaRequestEmailIDString) else {
            throw Abort(.badRequest, reason: "Invalid parameter `betaRequestEmailID`")
        }
        
        let user = try req.auth.require(User.self)
        
        return user.$organization.load(on: req.db).flatMapThrowing {
            if !user.organization.isSuperOrg {
                throw Abort(.unauthorized, reason: "Not a super org!")
            }
        }.flatMap {
         BetaRequestEmail.query(on: req.db)
            .filter(\.$id == betaRequestEmailID)
            .first()
            .unwrap(or: Abort(.notFound))
            .flatMap { $0.delete(on: req.db) }
            .map { .ok }
        }
    }
}
