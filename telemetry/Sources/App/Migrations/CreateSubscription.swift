import Fluent

extension Subscription {
    struct CreateMigration: Fluent.Migration {
        func prepare(on database: Database) -> EventLoopFuture<Void> {
            database.schema("subscriptions")
                .id()
                .field("plan", .uuid, .required, .references("plans", "id", onDelete: .cascade, onUpdate: .noAction))
                .field("organization", .uuid, .required, .references("organizations", "id", onDelete: .cascade, onUpdate: .noAction))
                .field("valid_from", .datetime, .required)
                .field("valid_until", .datetime, .required)
                .field("amount_paid", .int, .required)
                .create()
        }

        func revert(on database: Database) -> EventLoopFuture<Void> {
            database.schema("subscriptions").delete()
        }
    }
}
