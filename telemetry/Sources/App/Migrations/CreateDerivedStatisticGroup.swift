import Fluent

extension DerivedStatisticGroup {
    struct Migration: Fluent.Migration {
        var name: String { "CreateDerivedStatisticGroup" }

        func prepare(on database: Database) -> EventLoopFuture<Void> {
            database.schema(DerivedStatisticGroup.schema)
                .id()
                .field("app_id", .uuid, .required, .references(App.schema, "id"))
                .foreignKey("app_id", references: App.schema, "id", onDelete: .cascade, onUpdate: .noAction)
                .field("title", .string, .required)
                .create()
        }

        func revert(on database: Database) -> EventLoopFuture<Void> {
            database.schema(DerivedStatisticGroup.schema).delete()
        }
    }
}
