import Fluent
import Vapor

final class BetaRequestEmail: Model, Content {
    static let schema = "beta_request_emails"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "email")
    var email: String

    @Field(key: "requested_at")
    var requestedAt: Date

    @Field(key: "is_fulfilled")
    var isFulfilled: Bool
}
