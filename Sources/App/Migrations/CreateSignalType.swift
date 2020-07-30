import Fluent

extension SignalType  {
    struct Migration: Fluent.Migration {
        var name: String { "CreateSignalType" }
        var schema = SignalType.schema

        func prepare(on database: Database) -> EventLoopFuture<Void> {
            database.schema(schema)
                .id()
                .field("name", .string, .required)
                .field("app_id", .uuid, .required, .references("apps", "id"))
                .create()
        }

        func revert(on database: Database) -> EventLoopFuture<Void> {
            database.schema(schema).delete()
        }
    }
}
