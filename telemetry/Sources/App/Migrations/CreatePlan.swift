import Fluent

extension Plan {
    struct CreateMigration: Fluent.Migration {
        func prepare(on database: Database) -> EventLoopFuture<Void> {
            database.schema("plans")
                .id()
                .field("title", .string, .required)
                .field("description", .string)
                .field("order", .int, .required, .sql(raw: "DEFAULT 0"))
                .field("is_public", .bool, .required, .sql(raw: "DEFAULT false"))
                .field("discount_code", .string)
                .field("time_period", .string, .required)
                .field("included_signals", .int, .required)
                .field("included_organization_members", .int, .required)
                .field("included_apps", .int, .required)
                .field("has_priority_email_support", .bool, .required)
                .field("has_phone_support", .bool, .required)
                .create()
        }

        func revert(on database: Database) -> EventLoopFuture<Void> {
            database.schema("plans").delete()
        }
    }
}
