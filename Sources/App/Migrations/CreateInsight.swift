import Fluent

extension Insight {
    struct Migration: Fluent.Migration {
        var name: String { "CreateInsight" }

        func prepare(on database: Database) -> EventLoopFuture<Void> {
            database.schema(Insight.schema)
                .id()
                .field("group_id", .uuid, .required, .references(InsightGroup.schema, "id"))
                .foreignKey("group_id", references: InsightGroup.schema, "id", onDelete: .cascade, onUpdate: .noAction)
                .field("title", .string, .required)
                .field("insight_type", .string, .required)
                .field("configuration", .dictionary(of: .string))
                .create()
        }

        func revert(on database: Database) -> EventLoopFuture<Void> {
            database.schema(Insight.schema).delete()
        }
    }
}
