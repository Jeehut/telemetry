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
                .field("time_interval", .double)
                .field("configuration", .dictionary(of: .string))
                .create()
        }

        func revert(on database: Database) -> EventLoopFuture<Void> {
            database.schema(Insight.schema).delete()
        }
    }
    
    struct Migration2: Fluent.Migration {
        var name: String { "CreateInsight_002" }

        func prepare(on database: Database) -> EventLoopFuture<Void> {
            database.schema(Insight.schema)
                .field("order", .double)
                .update()
        }

        func revert(on database: Database) -> EventLoopFuture<Void> {
            database.schema(Insight.schema)
                .deleteField("order")
                .update()
        }
    }
}
