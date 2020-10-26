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

    struct AddIsSuperOrgField: Fluent.Migration {
        func prepare(on database: Database) -> EventLoopFuture<Void> {
            database.schema("organizations")
                .field("is_super_org", .bool, .required, .sql(raw: "DEFAULT false"))
                .update()
        }

        func revert(on database: Database) -> EventLoopFuture<Void> {
            database.schema("organizations")
                .deleteField("is_super_org")
                .update()
        }
    }
}
