//
//  File.swift
//  
//
//  Created by Daniel Jilg on 29.07.20.
//

import Vapor

class OrganizationAPIController {
    struct Organization: Content {
        let id: Int
        let title: String
    }

    static let organizations = [
        Organization(id: 1, title: "breakthesystem"),
        Organization(id: 2, title: "Weyland Yutani"),
        Organization(id: 3, title: "Microsoft"),
    ]

    func getOrganizations(req: Request) -> [Organization] {
        return Self.organizations
    }

    func getOrganization(req: Request) throws -> Organization {
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
