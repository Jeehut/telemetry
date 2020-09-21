import Fluent
import Vapor


struct DerivedStatisticGroupController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let insights = routes.grouped(UserToken.authenticator())
        insights.get(use: getAll)
    }
    
    func getAll(req: Request) throws -> EventLoopFuture<[DerivedStatisticGroup]> {
        guard let appIDString = req.parameters.get("appID"),
              let appID = UUID(appIDString) else {
            throw Abort(.badRequest, reason: "Invalid parameter `appID`")
        }
        
        let user = try req.auth.require(User.self)
        // TODO: Only return apps for this user's org
        
        return DerivedStatisticGroup.query(on: req.db)
            .with(\.$derivedStatistics)
            .filter(\.$app.$id == appID)
            .all()
    }
}
