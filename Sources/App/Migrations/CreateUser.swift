import Fluent

extension User {
    struct Migration: Fluent.Migration {
        var name: String { "CreateUser" }

        func prepare(on database: Database) -> EventLoopFuture<Void> {
            database.schema("users")
                .id()
                .field("first_name", .string, .required)
                .field("last_name", .string, .required)
                .field("email", .string, .required)
                .field("password_hash", .string, .required)
                .field("organization_id", .uuid, .required, .references("organizations", "id"))
                .foreignKey("organization_id", references: Organization.schema, "id", onDelete: .cascade, onUpdate: .noAction)
                .unique(on: "email")
                .create()
        }

        func revert(on database: Database) -> EventLoopFuture<Void> {
            database.schema("users").delete()
        }
    }
}
