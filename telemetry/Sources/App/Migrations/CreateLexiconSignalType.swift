import Fluent

extension LexiconSignalType  {
    struct Migration: Fluent.Migration {
        
        func prepare(on database: Database) -> EventLoopFuture<Void> {
            database.schema("lexicon_signal_types")
                .id()
                .field("app_id", .uuid, .required, .references(App.schema, "id"))
                .field("first_seen_at", .datetime, .required, .sql(raw: "DEFAULT now()"))
                .field("is_hidden", .bool, .required, .sql(raw: "DEFAULT false"))
                .field("signal_type", .string, .required)
                .unique(on: "app_id", "signal_type")
                .create()
        }
        
        func revert(on database: Database) -> EventLoopFuture<Void> {
            database.schema("lexicon_signal_types").delete()
        }
    }
    
    struct Migration2: Fluent.Migration {
        func prepare(on database: Database) -> EventLoopFuture<Void> {
            database.schema("lexicon_signal_types")
                .delete()
                .flatMap {
                    database.schema("lexicon_signal_types")
                        .id()
                        .field("app_id", .uuid, .required, .references(App.schema, "id", onDelete: .cascade, onUpdate: .cascade))
                        .field("first_seen_at", .datetime, .required, .sql(raw: "DEFAULT now()"))
                        .field("is_hidden", .bool, .required, .sql(raw: "DEFAULT false"))
                        .field("signal_type", .string, .required)
                        .unique(on: "app_id", "signal_type")
                        .create()
                }
            
        }
        
        func revert(on database: Database) -> EventLoopFuture<Void> {
            database.schema("lexicon_signal_types").delete().flatMap {
                database.schema("lexicon_signal_types")
                    .id()
                    .field("app_id", .uuid, .required, .references(App.schema, "id"))
                    .field("first_seen_at", .datetime, .required, .sql(raw: "DEFAULT now()"))
                    .field("is_hidden", .bool, .required, .sql(raw: "DEFAULT false"))
                    .field("signal_type", .string, .required)
                    .unique(on: "app_id", "signal_type")
                    .create()
            }
        }
    }
    
}
