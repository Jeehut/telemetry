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

    app.get("hello") { req -> String in
        return "Hello, world!"
    }

    try app.register(collection: TodoController())
}
