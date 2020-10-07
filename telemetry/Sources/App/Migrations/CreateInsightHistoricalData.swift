import Fluent

extension InsightHistoricalData {
    struct Migration: Fluent.Migration {
        var name: String { "CreateInsightHistoricalData" }

        func prepare(on database: Database) -> EventLoopFuture<Void> {
            database.schema(InsightHistoricalData.schema)
                .id()
                .field("insight_id", .uuid, .required, .references(Insight.schema, "id"))
                .foreignKey("insight_id", references: Insight.schema, "id", onDelete: .cascade, onUpdate: .noAction)
                .field("calculated_at", .datetime, .required)
                .field("data", .dictionary(of: .float))
                .create()
        }

        func revert(on database: Database) -> EventLoopFuture<Void> {
            database.schema(InsightHistoricalData.schema).delete()
        }
    }
    
    struct Migration2: Fluent.Migration {
        var name: String { "InsightHistoricalData_002" }

        func prepare(on database: Database) -> EventLoopFuture<Void> {
            database.schema(InsightHistoricalData.schema).delete()
            
            return database.schema(InsightHistoricalData.schema)
                .id()
                .field("insight_id", .uuid, .required, .references(Insight.schema, "id", onDelete: .cascade, onUpdate: .noAction))
                .field("calculated_at", .datetime, .required)
                .field("data", .dictionary(of: .float))
                .create()
        }

        func revert(on database: Database) -> EventLoopFuture<Void> {
            database.schema(InsightHistoricalData.schema).delete()
        }
    }
}
