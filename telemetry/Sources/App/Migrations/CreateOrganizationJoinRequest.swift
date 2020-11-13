import Fluent

extension OrganizationJoinRequest {
    struct Migration: Fluent.Migration {
        func prepare(on database: Database) -> EventLoopFuture<Void> {
            database.schema("organization_join_requests")
                .id()
                .field("organization_id", .uuid, .required, .references("organizations", "id"))
                .field("registration_token", .string, .required)
                .create()
        }
        
        func revert(on database: Database) -> EventLoopFuture<Void> {
            database.schema("organization_join_requests").delete()
        }
    }
}
