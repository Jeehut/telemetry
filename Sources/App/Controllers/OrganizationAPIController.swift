//
//  File.swift
//  
//
//  Created by Daniel Jilg on 29.07.20.
//

import Vapor

class OrganizationAPIController {
    struct OrgOrg: Content {
        let id: Int
        let title: String
    }

    static let organizations = [
        OrgOrg(id: 1, title: "breakthesystem"),
        OrgOrg(id: 2, title: "Weyland Yutani"),
        OrgOrg(id: 3, title: "Microsoft"),
    ]

    func getOrganizations(req: Request) -> [OrgOrg] {
        return Self.organizations
    }

    func getOrganization(req: Request) throws -> OrgOrg {
        guard
            let organizationIDString = req.parameters.get("organizationID"),
            let organizationID = Int(organizationIDString),
            let organization = Self.organizations.first(where: { $0.id == organizationID })
        else { throw Abort(.notFound) }

        return organization
    }
}

extension OrganizationAPIController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.get("", use: getOrganizations)
        routes.get(":organizationID", use: getOrganization)
    }
}
