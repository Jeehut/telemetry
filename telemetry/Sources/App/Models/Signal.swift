import Fluent
import Vapor

final class Signal: Model, Content {
    static let schema = "signals"

    @ID(key: .id)
    var id: UUID?
    
    @Parent(key: "app_id")
    var app: App
    
    @Timestamp(key: "received_at", on: .create)
    var receivedAt: Date?

    @Field(key: "client_user")
    var clientUser: String

    @Field(key: "signal_type")
    var type: String
    
    @Field(key: "payload")
    var payload: Dictionary<String, String>?
}
