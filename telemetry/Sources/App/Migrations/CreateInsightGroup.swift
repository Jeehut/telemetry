import Fluent

extension InsightGroup {
    struct Migration: Fluent.Migration {
        var name: String { "CreateInsightGroup" }

        func prepare(on database: Database) -> EventLoopFuture<Void> {
            database.schema(InsightGroup.schema)
                .id()
                .field("app_id", .uuid, .required, .references(App.schema, "id"))
                .foreignKey("app_id", references: App.schema, "id", onDelete: .cascade, onUpdate: .noAction)
                .field("title", .string, .required)
                .create()
        }

        func revert(on database: Database) -> EventLoopFuture<Void> {
            database.schema(InsightGroup.schema).delete()
        }
    }
    
    struct AddOrderField: Fluent.Migration {
        func prepare(on database: Database) -> EventLoopFuture<Void> {
            database.schema(InsightGroup.schema)
                .field("order", .double)
                .update()
        }
        
        func revert(on database: Database) -> EventLoopFuture<Void> {
            database.schema(InsightGroup.schema)
                .deleteField("order")
                .update()
        }
    }
}
