//
//  FrontPageController.swift
//  
//
//  Created by Daniel Jilg on 13.10.20.
//

import Fluent
import Vapor
import FluentPostgresDriver

class ContextsController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.get("frontpage", use: getFrontpageContext)
    }
    
    struct FrontpageContext: Content {
        var numberOfOrganizations: Int?
        var numberOfApps: Int?
        var numberOfInsights: Int?
        var numberOfSignals: Int?
    }
    
    func getFrontpageContext(req: Request) throws -> EventLoopFuture<FrontpageContext> {
        let postgres = req.db as! PostgresDatabase

        let countSignalsQuery = "SELECT reltuples::bigint FROM pg_catalog.pg_class WHERE relname = 'signals';"
        let countInsightsQuery = "SELECT reltuples::bigint FROM pg_catalog.pg_class WHERE relname = 'insights';"
        let countAppsQuery = "SELECT reltuples::bigint FROM pg_catalog.pg_class WHERE relname = 'apps';"
        let countOrgsQuery = "SELECT reltuples::bigint FROM pg_catalog.pg_class WHERE relname = 'organizations';"

        return postgres.simpleQuery(countSignalsQuery)
            .map { postgresRows in
                return FrontpageContext(
                    numberOfOrganizations: nil,
                    numberOfApps: nil,
                    numberOfInsights: nil,
                    numberOfSignals: postgresRows.first?.column("reltuples")?.int)
            }
            .flatMap { context in
                postgres.simpleQuery(countInsightsQuery).map { postgresRows in
                    return FrontpageContext(
                        numberOfOrganizations: nil,
                        numberOfApps: nil,
                        numberOfInsights: postgresRows.first?.column("reltuples")?.int,
                        numberOfSignals: context.numberOfSignals)
                }
            }
            .flatMap { context in
                postgres.simpleQuery(countAppsQuery).map { postgresRows in
                    return FrontpageContext(
                        numberOfOrganizations: nil,
                        numberOfApps: postgresRows.first?.column("reltuples")?.int,
                        numberOfInsights: context.numberOfInsights,
                        numberOfSignals: context.numberOfSignals)
                }
            }
            .flatMap { context in
                postgres.simpleQuery(countOrgsQuery).map { postgresRows in
                    return FrontpageContext(
                        numberOfOrganizations: postgresRows.first?.column("reltuples")?.int,
                        numberOfApps: context.numberOfApps,
                        numberOfInsights: context.numberOfInsights,
                        numberOfSignals: context.numberOfSignals)
                }
            }
    }
}
