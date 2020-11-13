import Vapor
import Fluent

final class OrganizationJoinRequest: Model, Content {
    static let schema = "organization_join_requests"

    @ID(key: .id)
    var id: UUID?
    
    @Parent(key: "organization_id")
    var organization: Organization
    
    @Field(key: "registration_token")
    var registrationToken: String
}
