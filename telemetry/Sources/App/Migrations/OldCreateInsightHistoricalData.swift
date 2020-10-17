import Fluent

extension OldInsightHistoricalData {
    struct Migration: Fluent.Migration {
        var name: String { "CreateInsightHistoricalData" }

        func prepare(on database: Database) -> EventLoopFuture<Void> {
            database.schema(OldInsightHistoricalData.schema)
                .id()
                .field("insight_id", .uuid, .required, .references(OldInsight.schema, "id"))
                .foreignKey("insight_id", references: OldInsight.schema, "id", onDelete: .cascade, onUpdate: .noAction)
                .field("calculated_at", .datetime, .required)
                .field("data", .dictionary(of: .float))
                .create()
        }

        func revert(on database: Database) -> EventLoopFuture<Void> {
            database.schema(OldInsightHistoricalData.schema).delete()
        }
    }
    
    struct Migration2: Fluent.Migration {
        var name: String { "InsightHistoricalData_002" }

        func prepare(on database: Database) -> EventLoopFuture<Void> {
            database.schema(OldInsightHistoricalData.schema).delete()
            
            return database.schema(OldInsightHistoricalData.schema)
                .id()
                .field("insight_id", .uuid, .required, .references(OldInsight.schema, "id", onDelete: .cascade, onUpdate: .noAction))
                .field("calculated_at", .datetime, .required)
                .field("data", .dictionary(of: .float))
                .create()
        }

        func revert(on database: Database) -> EventLoopFuture<Void> {
            database.schema(OldInsightHistoricalData.schema).delete()
        }
    }
}
