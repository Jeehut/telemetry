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


    try app.register(collection: TodoController())

    let apiRoutes = app.grouped("api", "v1")
    try apiRoutes.grouped("users").register(collection: RegistrationContoller())
    try apiRoutes.grouped("organizations").register(collection: OrganizationAPIController())
    try apiRoutes.grouped("apps").register(collection: AppController())
    try apiRoutes.grouped("signals").register(collection: SignalDeliveryController())
}
