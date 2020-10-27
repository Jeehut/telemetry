import Fluent
import Vapor

class BetaRequestEmailsController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.get(use: list)
        routes.post(use: create)
        routes.patch(":betaRequestEmailID", use: update)
    }

    func list(req: Request) throws -> EventLoopFuture<[BetaRequestEmail]> {
        let user = try req.auth.require(User.self)
        return user.$organization.load(on: req.db).flatMapThrowing {
            if !user.organization.isSuperOrg {
                throw Abort(.unauthorized, reason: "Not a super org!")
            }
        }.flatMap {
            BetaRequestEmail.query(on: req.db)
                .filter(\.$isFulfilled == false)
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

        let betaRequestEmail = BetaRequestEmail()
        betaRequestEmail.email = emailRequestBody.email
        betaRequestEmail.requestedAt = Date()
        betaRequestEmail.isFulfilled = false

        return betaRequestEmail.save(on: req.db)
            .map { HTTPStatus.ok }
    }

    func update(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        struct EmailRequestUpdateBody: Content {
            let isFulfulled: Bool
        }

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
            BetaRequestEmail
                .query(on: req.db)
                .filter(\.$id == betaRequestEmailID)
                .first()
                .unwrap(or: Abort(.notFound))
        }.flatMapThrowing { emailRequest in
            let emailUpdateBody = try req.content.decode(EmailRequestUpdateBody.self)
            emailRequest.isFulfilled = emailUpdateBody.isFulfulled
            _ = emailRequest.save(on: req.db)
        }.map {
            HTTPStatus.ok
        }
    }
}
