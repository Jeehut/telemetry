import Fluent

extension Signal  {
    struct Migration: Fluent.Migration {
        var name: String { "CreateSignal" }
        var schema = Signal.schema

        func prepare(on database: Database) -> EventLoopFuture<Void> {
            database.schema(schema)
                .id()
                .field("received_at", .date, .required)
                .field("client_user_id", .uuid, .required, .references("client_users", "id"))
                .field("signal_type_id", .uuid, .required, .references("signal_types", "id"))
                .create()
        }

        func revert(on database: Database) -> EventLoopFuture<Void> {
            database.schema(schema).delete()
        }
    }
}
