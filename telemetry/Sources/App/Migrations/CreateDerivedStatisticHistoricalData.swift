import Fluent

extension DerivedStatisticHistoricalData {
    struct Migration: Fluent.Migration {
        var name: String { "CreateDerivedStatisticHistoricalData" }

        func prepare(on database: Database) -> EventLoopFuture<Void> {
            database.schema(DerivedStatisticHistoricalData.schema)
                .id()
                .field("statistics", .dictionary(of: .int), .required)
                .field("calculated_at", .datetime, .required)
                .field("derivedstatistic_id", .uuid, .required, .references(DerivedStatistic.schema, "id"))
                .foreignKey("derivedstatistic_id", references: DerivedStatistic.schema, "id", onDelete: .cascade, onUpdate: .noAction)
                .create()
        }

        func revert(on database: Database) -> EventLoopFuture<Void> {
            database.schema(DerivedStatisticGroup.schema).delete()
        }
    }
}
