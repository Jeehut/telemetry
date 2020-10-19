import Fluent

extension Insight {
    struct CreationMigration: Fluent.Migration {
        func prepare(on database: Database) -> EventLoopFuture<Void> {
            database.schema("insights")
                .id()
                .field("group_id", .uuid, .required, .references(InsightGroup.schema, "id", onDelete: .cascade, onUpdate: .noAction))
                .field("order", .double)
                .field("title", .string, .required)
                .field("subtitle", .string)
                .field("signal_type", .string)
                .field("unique_user", .bool, .required)
                .field("filters", .dictionary(of: .string))
                .field("rolling_window_size", .double, .required)
                .field("breakdown_key", .string)
                .field("display_mode", .string, .required)
                .create()
        }

        func revert(on database: Database) -> EventLoopFuture<Void> {
            database.schema("insights").delete()
        }
    }
    
    struct DeleteOldTablesMigration: Fluent.Migration {
        func prepare(on database: Database) -> EventLoopFuture<Void> {
            database.schema("insight_historical_data")
                .delete()
                .flatMap {
                    database.schema("insight").delete()
                }
        }
        
        func revert(on database: Database) -> EventLoopFuture<Void> {
            fatalError("This migration is not revertable")
        }
    }
}
