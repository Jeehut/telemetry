import Fluent

extension BetaRequestEmail {
    struct Migration: Fluent.Migration {
        func prepare(on database: Database) -> EventLoopFuture<Void> {
            database.schema("beta_request_emails")
                .id()
                .field("email", .string, .required)
                .field("requested_at", .datetime, .required)
                .field("is_fulfilled", .bool, .required, .sql(raw: "DEFAULT false"))
                .unique(on: "email")
                .create()
        }

        func revert(on database: Database) -> EventLoopFuture<Void> {
            database.schema("beta_request_emails").delete()
        }
    }
}
