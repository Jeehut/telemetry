import Fluent
import Vapor


struct UserCountsController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let userCountGroups = routes.grouped(UserToken.authenticator())
        userCountGroups.get(use: getUserCountGroups)
        
    }
    
    
    func getUserCountGroups(req: Request) throws -> EventLoopFuture<[UserCountGroup]> {
        guard let appIDString = req.parameters.get("appID"),
              let appID = UUID(appIDString) else {
            throw Abort(.badRequest, reason: "Invalid parameter `appID`")
        }
        
        let user = try req.auth.require(User.self)
        // TODO: Only return apps for this user's org
        
        return UserCountGroup.query(on: req.db)
            .filter(\.$app.$id == appID)
            .all()
            .map { groups in
                let mockGroups: [UserCountGroup] = [
                    UserCountGroup(), UserCountGroup(), UserCountGroup()
                ]
                return mockGroups
            }
    }
}
