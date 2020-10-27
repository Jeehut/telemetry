import Fluent

extension LexiconPayloadKey  {
    struct Migration: Fluent.Migration {

        func prepare(on database: Database) -> EventLoopFuture<Void> {
            database.schema("lexicon_payload_keys")
                .id()
                .field("app_id", .uuid, .required, .references(App.schema, "id"))
                .field("first_seen_at", .date, .required, .sql(raw: "DEFAULT now()"))
                .field("is_hidden", .bool, .required, .sql(raw: "DEFAULT false"))
                .field("payload_key", .string, .required)
                .unique(on: "app_id", "payload_key")
                .create()
        }

        func revert(on database: Database) -> EventLoopFuture<Void> {
            database.schema("lexicon_payload_keys").delete()
        }
    }
}
