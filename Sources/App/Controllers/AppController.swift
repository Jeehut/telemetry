import Fluent
import Vapor
import FluentSQL


struct AppController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let apps = routes.grouped(UserToken.authenticator())
        apps.get(use: index)
        apps.get(":appID", use: getSingle)
        apps.patch(":appID", use: update)

        apps.post(use: create)
    }
    
    func index(req: Request) throws -> EventLoopFuture<[App]> {
        let user = try req.auth.require(User.self)
        
        // Only show user's orgs' apps, thanks to @jhoughjr
        return App.query(on: req.db)
            .filter(\.$organization.$id == user.$organization.id)
            .all()
    }
    
    func getSingle(req: Request) throws -> EventLoopFuture<App> {
        guard let appIDString = req.parameters.get("appID"),
            let appID = UUID(appIDString) else {
            throw Abort(.badRequest, reason: "Invalid parameter `appID`")
        }
        
        let user = try req.auth.require(User.self)
        
        return App.query(on: req.db)
            .filter(\.$organization.$id == user.$organization.id)
            .filter(\.$id == appID)
            .first()
            .unwrap(or: Abort(.notFound))
    }
    
    struct AppRequestBody: Content, Validatable {
        let name: String
        
        static func validations(_ validations: inout Validations) {
            validations.add("name", as: String.self, is: !.empty)
        }
    }
    
    func create(req: Request) throws -> EventLoopFuture<App> {
        let user = try req.auth.require(User.self)
        let appRequestBody = try req.content.decode(AppRequestBody.self)
        let app = App()
        app.name = appRequestBody.name
        app.$organization.id = user.$organization.id
        return app.save(on: req.db).map { app }
    }
    
    struct PatchAppRequestBody: Content {
        let name: String?
    }
    
    func update(req: Request) throws -> EventLoopFuture<App> {
        guard let appIDString = req.parameters.get("appID"),
            let appID = UUID(appIDString) else {
            throw Abort(.badRequest, reason: "Invalid parameter `appID`")
        }
        
        let patchAppRequestBody = try req.content.decode(PatchAppRequestBody.self)
        
        return App.find(appID, on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { app in
                if let name = patchAppRequestBody.name {
                    app.name = name
                }
                
                return app.update(on: req.db)
                    .map { app }
            }
    }
}
