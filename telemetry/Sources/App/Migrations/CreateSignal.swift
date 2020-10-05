import Fluent

extension Signal  {
    struct Migration: Fluent.Migration {
        var name: String { "CreateSignal" }
        var schema = Signal.schema

        func prepare(on database: Database) -> EventLoopFuture<Void> {
            database.schema(schema)
                .id()
                .field("app_id", .uuid, .required, .references(App.schema, "id"))
                .foreignKey("app_id", references: App.schema, "id", onDelete: .cascade, onUpdate: .noAction)
                .field("received_at", .date, .required)
                .field("client_user", .string, .required)
                .field("signal_type", .string, .required)
                .field("payload", .dictionary(of: .string))
                .create()
        }

        func revert(on database: Database) -> EventLoopFuture<Void> {
            database.schema(schema).delete()
        }
    }
}

extension Signal {
    struct UpdateReceivedAt: Fluent.Migration {
        func prepare(on database: Database) -> EventLoopFuture<Void> {
            database.schema(schema)
                .updateField("received_at", .datetime)
                .update()
        }

        func revert(on database: Database) -> EventLoopFuture<Void> {
            database.schema(schema)
                .updateField("received_at", .date)
                .update()
        }
    }
}
