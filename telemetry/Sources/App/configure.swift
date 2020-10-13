import Fluent
import FluentSQLiteDriver
import Vapor
import Leaf
import FluentPostgresDriver

// configures your application
public func configure(_ app: Application) throws {
    // uncomment to serve files from /Public folder
    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    app.views.use(.leaf)
    app.leaf.cache.isEnabled = app.environment.isRelease

    try CustomDatabaseConfiguration.configureDatabase(app)
    
    try MigrationConfiguration.configureMigrations(app)

    // register routes
    try routes(app)
}
