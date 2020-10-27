import Fluent
import Vapor

final class LexiconPayloadKey: Model, Content {
    static let schema = "lexicon_payload_keys"

    @ID(key: .id)
    var id: UUID?

    @Parent(key: "app_id")
    var app: App

    @Field(key: "first_seen_at")
    var firstSeenAt: Date

    /// If true, don't include this lexicon item in autocomplete lists
    @Field(key: "is_hidden")
    var isHidden: Bool

    @Field(key: "payload_key")
    var payloadKey: String

    static func from(_ signal: Signal) -> [LexiconPayloadKey] {
        var payloadKeys: [LexiconPayloadKey] = []

        guard let payload = signal.payload else { return payloadKeys }

        for key in payload.keys {
            let lexiconPayloadKey = LexiconPayloadKey()
            lexiconPayloadKey.$app.id = signal.$app.id
            lexiconPayloadKey.payloadKey = key
            payloadKeys.append(lexiconPayloadKey)
        }

        return payloadKeys
    }
}
