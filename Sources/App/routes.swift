import Fluent
import Vapor

struct Index: Codable {
    var title: String
    var description: String
}

struct Page: Codable {
    var content: String
}

struct Context: Codable {
    var index: Index
    var page: Page
}

func routes(_ app: Application) throws {
    app.get { req -> EventLoopFuture<View> in
        let context = Context(index: .init(title: "My page", description: "This is my Page"),
                                      page: .init(content: "Welcome to my page!"))

                return req.view.render("page", context)
    }

    // TODO: Put this in a versioned api
    let passwordProtected = app.grouped(User.authenticator())
    passwordProtected.post("login") { req -> EventLoopFuture<UserToken> in
        let user = try req.auth.require(User.self)
        let token = try user.generateToken()
        return token.save(on: req.db)
            .map { token }
    }

    let tokenProtected = app.grouped(UserToken.authenticator())
    tokenProtected.get("me") { req -> User in
        try req.auth.require(User.self)
    }

    try app.register(collection: TodoController())

    let apiRoutes = app.grouped("api", "v1")
    try apiRoutes.grouped("register").register(collection: RegistrationContoller())
    try apiRoutes.grouped("organizations").register(collection: OrganizationAPIController())
}
