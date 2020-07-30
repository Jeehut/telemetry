import Fluent
import Vapor

final class SignalType: Model, Content {
    static let schema = "signal_types"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "name")
    var name: String

    @Parent(key: "app_id")
    var app: App
}
