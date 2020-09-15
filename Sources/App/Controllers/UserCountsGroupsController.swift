import Fluent
import Vapor


struct UserCountGroupsController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let userCountGroups = routes.grouped(UserToken.authenticator())
        userCountGroups.get(use: getAll)
        userCountGroups.post(use: create)
        userCountGroups.delete(":userCountGroupID", use: delete)
    }
    
    func getAll(req: Request) throws -> EventLoopFuture<[UserCountGroup]> {
        guard let appIDString = req.parameters.get("appID"),
              let appID = UUID(appIDString) else {
            throw Abort(.badRequest, reason: "Invalid parameter `appID`")
        }
        
        let user = try req.auth.require(User.self)
        // TODO: Only return apps for this user's org
        
        return UserCountGroup.query(on: req.db)
            .with(\.$data)
            .filter(\.$app.$id == appID)
            .sort(\.$timeInterval, .descending)
            .all()
    }
    
//
//    // Define the dates
//    // TODO: norm them to distinct 24h slots?
//    let earlierDate = Date(timeIntervalSinceNow: userCountGroup.timeInterval)
//    let laterDate = Date()
//
//
//    return userCountGroupSaved.flatMap { userCountGroup in
//        // SELECT COUNT(client_user) FROM SIGNALS WHERE app_id="5AF9FDB3-6712-4C73-B367-958F367CC154";
//        return Signal.query(on: req.db)
//            .filter(\.$app.$id == appID)
//            .filter(\.$receivedAt > earlierDate)
//            .filter(\.$receivedAt < laterDate)
//            .unique()
//            .count(\.$clientUser)
//    }.flatMap { userCountNumber in
//
//        let userCount = UserCount()
//        userCount.calculatedAt = laterDate
//        userCount.count = userCountNumber
//        userCount.$userCountGroup.id = userCountGroup.id!
//        return userCount.save(on: req.db)
//    }.flatMap {
//        return userCountGroupSaved
//    }
    
    func create(req: Request) throws -> EventLoopFuture<UserCountGroup> {
        struct UserCountCreateRequestBody: Content, Validatable {
            let title: String
            let timeInterval: TimeInterval
            
            static func validations(_ validations: inout Validations) {
                validations.add("title", as: String.self, is: !.empty)
            }
        }
        
        guard let appIDString = req.parameters.get("appID"),
              let appID = UUID(appIDString) else {
            throw Abort(.badRequest, reason: "Invalid parameter `appID`")
        }
        
        let user = try req.auth.require(User.self)
        let userCountGroupRequestBody = try req.content.decode(UserCountCreateRequestBody.self)
        
        let userCountGroup = UserCountGroup()
        userCountGroup.title = userCountGroupRequestBody.title
        userCountGroup.timeInterval = userCountGroupRequestBody.timeInterval
        userCountGroup.$app.id = appID
        
        return userCountGroup.save(on: req.db).map { userCountGroup }
    }
    
    func delete(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        guard let userCountGroupIDString = req.parameters.get("userCountGroupID"),
              let userCountGroupID = UUID(userCountGroupIDString) else {
            throw Abort(.badRequest, reason: "Invalid parameter `userCountGroupIDString`")
        }
        
        let user = try req.auth.require(User.self)
        
        // TODO: Filter by user org
        return UserCountGroup.query(on: req.db)
            .filter(\.$id == userCountGroupID)
            .first()
            .unwrap(or: Abort(.notFound))
            .flatMap { $0.delete(on: req.db) }
            .map { .ok }
    }
}