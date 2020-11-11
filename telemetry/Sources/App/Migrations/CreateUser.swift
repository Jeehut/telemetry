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
    
    struct Migration2: Fluent.Migration {
        func prepare(on database: Database) -> EventLoopFuture<Void> {
            database.schema("users")
                .field("is_founding_user", .bool, .required, .sql(raw: "DEFAULT true"))
                .update()
        }

        func revert(on database: Database) -> EventLoopFuture<Void> {
            database.schema("users")
                .deleteField("is_founding_user")
                .update()
        }
    }
}
