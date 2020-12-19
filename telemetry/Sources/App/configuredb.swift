import Fluent
import Vapor
import FluentPostgresDriver

struct CustomDatabaseConfiguration {
    static func configureDatabase(_ app: Application) throws {
        try app.databases.use(.postgres(url: "postgresql://breakthesystem@localhost:5432/breakthesystem"), as: .psql)
    }
}
