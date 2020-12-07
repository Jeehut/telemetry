import Fluent
import Vapor
import FluentPostgresDriver

class OrganizationAdminController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let orgAdmin = routes.grouped(UserToken.authenticator())
        orgAdmin.get(use: list)
    }

    struct OrganizationAdminListEntry: Content {
        let id: UUID
        let name: String
        let foundedAt: Date
        let sumSignals: Int
        let isSuperOrg: Bool
        let firstName: String?
        let lastName: String?
        let email: String
    }

    func list(req: Request) throws -> EventLoopFuture<[OrganizationAdminListEntry]> {
        let user = try req.auth.require(User.self)
        return user.$organization.load(on: req.db).flatMapThrowing {
            if !user.organization.isSuperOrg {
                throw Abort(.unauthorized, reason: "Not a super org!")
            }
        }.flatMap {
            let query = """
                WITH
                appcounts AS (SELECT app_id, COUNT(app_id) from signals WHERE received_at >= date_trunc('month', CURRENT_DATE) GROUP BY app_id),
                app_organizations AS (SELECT organization_id, count FROM appcounts INNER JOIN apps on app_id = apps.id),
                organization_counts AS (SELECT SUM(count), organization_id FROM app_organizations GROUP BY organization_id),
                founding_users AS (SELECT organization_id, first_name, last_name, email FROM users WHERE is_founding_user = true)

            SELECT organizations.id::uuid AS organization_id, name as organization_name, now() AS founded_at, COALESCE(sum, 0) AS sum_signals, is_super_org, first_name, last_name, email FROM organization_counts
            RIGHT JOIN organizations ON organization_id = organizations.id
            RIGHT JOIN founding_users ON organizations.id = founding_users.organization_id
            ORDER BY sum_signals DESC, organization_name
            ;
            """

            let postgres = req.db as! PostgresDatabase
            return postgres.simpleQuery(query)
                .map { postgresRows in
                    var entries: [OrganizationAdminListEntry] = []

                    for row in postgresRows {
                        entries.append(
                            OrganizationAdminListEntry(
                                id: UUID(row.column("organization_id")!.string!)!,
                                name: row.column("organization_name")!.string!,
                                foundedAt: Date(),
                                sumSignals: row.column("sum_signals")!.int!,
                                isSuperOrg: row.column("is_super_org")!.bool!,
                                firstName: row.column("first_name")!.string,
                                lastName: row.column("last_name")!.string,
                                email: row.column("email")!.string!
                            )
                        )
                    }

                    return entries
                }
        }
    }

}
