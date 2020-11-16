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
    
    struct Migration2: Fluent.Migration {
        func prepare(on database: Database) -> EventLoopFuture<Void> {
            _ = database.schema("registration_tokens").delete()
            
            return database.schema("beta_request_emails")
                .field("registration_token", .string, .required, .sql(raw: "DEFAULT 'LOLNOPE123'"))
                .update()
        }
        
        func revert(on database: Database) -> EventLoopFuture<Void> {
            database.schema("registration_tokens")
                .id()
                .field("value", .string, .required)
                .field("is_used", .bool, .required)
                .create()
        }
    }
    
    struct Migration3: Fluent.Migration {
        func prepare(on database: Database) -> EventLoopFuture<Void> {
            return database.schema("beta_request_emails")
                .field("sent_at", .datetime)
                .update()
        }
        
        func revert(on database: Database) -> EventLoopFuture<Void> {
            database.schema("registration_tokens")
                .deleteField("sent_at")
                .update()
        }
    }
}
