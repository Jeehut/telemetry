import Fluent

extension ClientUser  {
    struct Migration: Fluent.Migration {
        var name: String { "CreateClientUser" }
        var schema = ClientUser.schema

        func prepare(on database: Database) -> EventLoopFuture<Void> {
            database.schema(schema)
                .id()
                .field("name", .string, .required)
                .field("nickname", .string)
                .field("created_at", .date)
                .unique(on: "name")
                .create()
        }

        func revert(on database: Database) -> EventLoopFuture<Void> {
            database.schema(schema).delete()
        }
    }
}
