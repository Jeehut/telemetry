import Fluent

extension UserCountGroup {
    struct Migration: Fluent.Migration {
        
        var name: String { "CreateUserCountGroup" }
        var schema = UserCountGroup.schema
        
        func prepare(on database: Database) -> EventLoopFuture<Void> {
            database.schema(schema)
                .id()
                .field("app_id", .uuid, .required, .references(App.schema, "id"))
                .foreignKey("app_id", references: App.schema, "id", onDelete: .cascade, onUpdate: .noAction)
                .field("title", .string, .required)
                .field("time_interval", .double)
                .create()
        }
        
        func revert(on database: Database) -> EventLoopFuture<Void> {
            database.schema(schema).delete()
        }
    }
}
