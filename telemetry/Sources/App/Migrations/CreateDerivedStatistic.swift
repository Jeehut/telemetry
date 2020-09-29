import Fluent

extension DerivedStatistic {
    struct Migration: Fluent.Migration {
        var name: String { "CreateDerivedStatistic" }

        func prepare(on database: Database) -> EventLoopFuture<Void> {
            database.schema(DerivedStatistic.schema)
                .id()
                .field("title", .string, .required)
                .field("payloadkey", .string, .required)
                .field("derivedstatisticgroup_id", .uuid, .required, .references(DerivedStatisticGroup.schema, "id"))
                .foreignKey("derivedstatisticgroup_id", references: DerivedStatisticGroup.schema, "id", onDelete: .cascade, onUpdate: .noAction)
                .create()
        }

        func revert(on database: Database) -> EventLoopFuture<Void> {
            database.schema(DerivedStatistic.schema).delete()
        }
    }
}