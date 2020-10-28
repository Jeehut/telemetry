import Fluent
import Vapor

class LexiconController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let lexicon = routes.grouped(UserToken.authenticator())
        lexicon.get("signaltypes", use: listSignalTypes)
        lexicon.get("payloadkeys", use: listPayloadKeys)
        lexicon.patch("signaltypes", ":lexiconItemID", use: updateSignalType)
        lexicon.patch("payloadkeys", ":lexiconItemID", use: updatePayloadKey)
    }

    func listSignalTypes(req: Request) throws -> EventLoopFuture<[LexiconSignalType]> {
        guard let appIDString = req.parameters.get("appID"),
              let appID = UUID(appIDString) else {
            throw Abort(.badRequest, reason: "Invalid parameter `appID`")
        }

        // TODO: Make sure app belongs to this user's org
        let user = try req.auth.require(User.self)

        return LexiconSignalType
            .query(on: req.db)
            .filter(\.$app.$id == appID)
            .sort(\.$firstSeenAt, .descending)
            .all()
    }

    func listPayloadKeys(req: Request) throws -> EventLoopFuture<[LexiconPayloadKey]> {
        guard let appIDString = req.parameters.get("appID"),
              let appID = UUID(appIDString) else {
            throw Abort(.badRequest, reason: "Invalid parameter `appID`")
        }

        // TODO: Make sure app belongs to this user's org
        let user = try req.auth.require(User.self)

        return LexiconPayloadKey
            .query(on: req.db)
            .filter(\.$app.$id == appID)
            .sort(\.$firstSeenAt, .descending)
            .all()
    }

    func updateSignalType(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        guard let lexiconItemIDString = req.parameters.get("lexiconItemID"),
              let lexiconItemID = UUID(lexiconItemIDString) else {
            throw Abort(.badRequest, reason: "Invalid parameter `lexiconItemID`")
        }

        let user = try req.auth.require(User.self)

        return LexiconSignalType
            .query(on: req.db)
            .filter(\.$id == lexiconItemID)
            .first()
            .unwrap(or: Abort(.notFound))
            .flatMapThrowing { lexiconItem in
                let updateBody = try req.content.decode(LexiconItemUpdateBody.self)
                lexiconItem.isHidden = updateBody.isHidden
                _ = lexiconItem.save(on: req.db)
            }.map {
                HTTPStatus.ok
            }
    }

    func updatePayloadKey(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        guard let lexiconItemIDString = req.parameters.get("lexiconItemID"),
              let lexiconItemID = UUID(lexiconItemIDString) else {
            throw Abort(.badRequest, reason: "Invalid parameter `lexiconItemID`")
        }

        let user = try req.auth.require(User.self)

        return LexiconPayloadKey
            .query(on: req.db)
            .filter(\.$id == lexiconItemID)
            .first()
            .unwrap(or: Abort(.notFound))
            .flatMapThrowing { lexiconItem in
                let updateBody = try req.content.decode(LexiconItemUpdateBody.self)
                lexiconItem.isHidden = updateBody.isHidden
                _ = lexiconItem.save(on: req.db)
            }.map {
                HTTPStatus.ok
            }
    }
}
