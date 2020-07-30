import Fluent
import Vapor

final class Signal: Model, Codable {
    static let schema = "signals"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "received_at")
    var receivedAt: Date

    @Parent(key: "client_user_id")
    var clientUser: ClientUser

    @Parent(key: "signal_type_id")
    var type: SignalType
}
