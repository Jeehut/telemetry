import Fluent
import Vapor
import FluentSQL


struct AppController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let apps = routes.grouped(UserToken.authenticator())
        apps.get(use: index)
        apps.post(use: create)
    }
    
    func index(req: Request) throws -> EventLoopFuture<[App]> {
        let user = try req.auth.require(User.self)
        
        // Only show user's orgs' apps, thanks to @jhoughjr
        return App.query(on: req.db)
            .filter(\.$organization.$id == user.$organization.id)
            .all()
    }
    
    struct AppRequestBody: Content, Validatable {
        static func validations(_ validations: inout Validations) {
            validations.add("name", as: String.self, is: !.empty)
        }
        
        let name: String
    }
    
    func create(req: Request) throws -> EventLoopFuture<App> {
        let user = try req.auth.require(User.self)
        let appRequestBody = try req.content.decode(AppRequestBody.self)
        let app = App()
        app.name = appRequestBody.name
        app.$organization.id = user.$organization.id
        return app.save(on: req.db).map { app }
    }
}
