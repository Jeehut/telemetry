import Fluent
import Vapor

/// A user of the software.
///
/// Users are always anonymized and only represented by a hash value, so privacy can be guaranteed.
final class ClientUser: Model, Content {
    static let schema = "client_users"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "name")
    var name: String

    @Field(key: "nickname")
    var nickname: String?

    @Field(key: "created_at")
    var createdAt: Date
}
