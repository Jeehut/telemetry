//
//  FrontPageController.swift
//  
//
//  Created by Daniel Jilg on 13.10.20.
//

import Fluent
import Vapor

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
        return Signal.query(on: req.db)
            .count()
            .flatMap { signalCount in
                Organization.query(on: req.db)
                    .count()
                    .map { orgCount in
                        return FrontpageContext(
                            numberOfOrganizations: orgCount,
                            numberOfApps: nil,
                            numberOfInsights: nil,
                            numberOfSignals: signalCount)
                    }
            }
            .flatMap { context in
                App.query(on: req.db)
                    .count()
                    .map { appCount in
                        var newContext = context
                        newContext.numberOfApps = appCount
                        return newContext
                    }
            }
            .flatMap { (context: FrontpageContext) in
                OldInsight.query(on: req.db)
                    .count()
                    .map { insightCount in
                        var newContext = context
                        newContext.numberOfInsights = insightCount
                        return newContext
                    }
            }
    }
}
