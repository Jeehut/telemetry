import Fluent

extension App  {
    struct Migration: Fluent.Migration {
        var name: String { "CreateApp" }
        var schema = App.schema

        func prepare(on database: Database) -> EventLoopFuture<Void> {
            database.schema(schema)
                .id()
                .field("name", .string, .required)
                .field("organization_id", .uuid, .required, .references("organizations", "id"))
                .foreignKey("organization_id", references: Organization.schema, "id", onDelete: .cascade, onUpdate: .noAction)
                .create()
        }

        func revert(on database: Database) -> EventLoopFuture<Void> {
            database.schema(schema).delete()
        }
    }
}
