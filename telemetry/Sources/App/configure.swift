import Fluent
import FluentSQLiteDriver
import Vapor
import FluentPostgresDriver

// configures your application
public func configure(_ app: Application) throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    try CustomDatabaseConfiguration.configureDatabase(app)
    
    try MigrationConfiguration.configureMigrations(app)

    try CustomEmailConfiguration.configureEmail(app)

    // register routes
    try routes(app)
}
