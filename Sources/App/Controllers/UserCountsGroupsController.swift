import Fluent
import Vapor


struct UserCountGroupsController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let userCountGroups = routes.grouped(UserToken.authenticator())
        userCountGroups.get(use: getAll)
        userCountGroups.post(use: create)
        userCountGroups.delete(":userCountGroupID", use: delete)
    }
    
    func getAll(req: Request) throws -> EventLoopFuture<[UserCountGroupDataTransferObject]> {
        guard let appIDString = req.parameters.get("appID"),
              let appID = UUID(appIDString) else {
            throw Abort(.badRequest, reason: "Invalid parameter `appID`")
        }
        
        let user = try req.auth.require(User.self)
        // TODO: Only return apps for this user's org
        
        return UserCountGroup.query(on: req.db)
            .with(\.$historiclData)
            .filter(\.$app.$id == appID)
            .sort(\.$timeInterval, .descending)
            .all()
            .mapEach { userCountGroup -> UserCountGroup in
                let furthestBack = Date(timeIntervalSinceNow: -3600*24*35) // Slightly over a month ago
                var currentDate = Date()
                
                while currentDate > furthestBack {
                    // Calculate the canonical start of day for the previous day
                    currentDate = Calendar.current.startOfDay(for: Date(timeInterval: -1, since: currentDate))
                    
                    // Check if there's a UserCount calculated at currentDate
                    guard userCountGroup.historiclData.filter({ userCount in return userCount.calculatedAt == currentDate }).isEmpty else {
                        continue
                    }
                    
                    // If not, create and save it
                    let earlierDate = Date(timeInterval: userCountGroup.timeInterval, since: currentDate)
                    let laterDate = currentDate
                    
                    _ = Signal.query(on: req.db)
                        .filter(\.$app.$id == appID)
                        .filter(\.$receivedAt > earlierDate)
                        .filter(\.$receivedAt < laterDate)
                        .unique()
                        .count(\.$clientUser)
                        .map { count in
                            let userCount = UserCount()
                            userCount.calculatedAt = laterDate
                            userCount.count = count
                            userCount.$userCountGroup.id = userCountGroup.id!
                            _ = userCount.save(on: req.db)
                        }
                    
                }
                
                return userCountGroup
            }
            .flatMapEach(on: req.eventLoop) { userCountGroup in
                
                // Retrieve the value at the current time
                let laterDate = Date()
                let earlierDate = Date(timeInterval: userCountGroup.timeInterval, since: laterDate)
                
                let omsn = Signal.query(on: req.db)
                    .filter(\.$app.$id == appID)
                    .filter(\.$receivedAt > earlierDate)
                    .filter(\.$receivedAt < laterDate)
                    .unique()
                    .count(\.$clientUser)
                    .map { count -> UserCountGroupDataTransferObject in
                        return UserCountGroupDataTransferObject(
                            id: userCountGroup.id,
                            app: ["id": userCountGroup.$app.id.uuidString],
                            title: userCountGroup.title,
                            timeInterval: userCountGroup.timeInterval,
                            historicalData: userCountGroup.historiclData,
                            rollingCurrentCount: count)
                    }
                
                return omsn
            }
    }
    
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
