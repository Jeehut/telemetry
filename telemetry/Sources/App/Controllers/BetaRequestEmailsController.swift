import Fluent
import Vapor

class BetaRequestEmailsController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let betarequests = routes.grouped(UserToken.authenticator())
        betarequests.get(use: list)
        betarequests.post(use: create)
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
}
