import Fluent
import Vapor

final class LexiconSignalType: Model, Content {
    static let schema = "lexicon_signal_types"

    @ID(key: .id)
    var id: UUID?

    @Parent(key: "app_id")
    var app: App

    @Field(key: "first_seen_at")
    var firstSeenAt: Date

    /// If true, don't include this lexicon item in autocomplete lists
    @Field(key: "is_hidden")
    var isHidden: Bool

    @Field(key: "signal_type")
    var type: String

    static func from(_ signal: Signal) -> LexiconSignalType {
        let lexiconSignalType = LexiconSignalType()
        lexiconSignalType.$app.id = signal.$app.id
        lexiconSignalType.type = signal.type
        return lexiconSignalType
    }
}
