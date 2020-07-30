import Fluent

extension Organization  {
    struct Migration: Fluent.Migration {
        var name: String { "CreateOrganization" }
        var schema = Organization.schema

        func prepare(on database: Database) -> EventLoopFuture<Void> {
            database.schema(schema)
                .id()
                .field("name", .string, .required)
                .create()
        }

        func revert(on database: Database) -> EventLoopFuture<Void> {
            database.schema(schema).delete()
        }
    }
}
