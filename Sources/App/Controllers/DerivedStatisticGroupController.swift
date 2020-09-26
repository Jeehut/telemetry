import Fluent
import Vapor


struct DerivedStatisticGroupController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let derivedStatisticGroups = routes.grouped(UserToken.authenticator())
        derivedStatisticGroups.get(use: getAll)
        derivedStatisticGroups.post(use: create)
        derivedStatisticGroups.post(":derivedStatisticGroupID", "derivedstatistics", use: createDerivedStatistic)
        derivedStatisticGroups.get(":derivedStatisticGroupID", "derivedstatistics", ":derivedStatisticID", use: getDerivedStatistic)
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
    
    func getDerivedStatistic(req: Request) throws -> EventLoopFuture<DerivedStatisticDataTransferObject> {
        guard let appIDString = req.parameters.get("appID"),
              let appID = UUID(appIDString),
              let derivedStatisticIDString = req.parameters.get("derivedStatisticID"),
              let derivedStatisticID = UUID(derivedStatisticIDString)
        else {
            throw Abort(.badRequest, reason: "Invalid parameter `appID`")
        }
        
        let user = try req.auth.require(User.self)
        // TODO: Only return apps for this user's org
        
        let timeInterval: TimeInterval = -3600*24
        // TODO: Save timeinterval in DerivedStatistic
        
        // Retrieve the value at the current time
        let laterDate = Date()
        let earlierDate = Date(timeInterval: timeInterval, since: laterDate)
        
        
        
         return DerivedStatistic.query(on: req.db)
            .filter(\.$id == derivedStatisticID)
            .first()
            .unwrap(or: Abort(.notFound))
            .flatMap { statistic in
                return Signal.query(on: req.db)
                    .filter(\.$app.$id == appID)
                    .filter(\.$receivedAt > earlierDate)
                    .filter(\.$receivedAt < laterDate)
                    .sort(\.$receivedAt, .descending)
                    .all()
                    .map { signals in
                        (statistic, signals)
                    }
            }
            .map { statisticTuple -> DerivedStatisticDataTransferObject in
                let statistic = statisticTuple.0
                let signals = statisticTuple.1
                let payloadKey = statistic.payloadKey
                
                var rollingStatistics: [String: Int] = [:]
                var knownUserIdentifiers: [String] = []
                
                for signal in signals {
                    guard let payloadDict = signal.payload, let payloadContent = payloadDict[payloadKey] else { continue }
                    
                    guard !knownUserIdentifiers.contains(signal.clientUser) else { continue }
                    
                    let currentAmountInStatistics = rollingStatistics[payloadContent, default: 0]
                    rollingStatistics[payloadContent] = currentAmountInStatistics + 1
                    knownUserIdentifiers.append(signal.clientUser)
                }
                
                return DerivedStatisticDataTransferObject(id: statistic.id!, title: statistic.title, payloadKey: statistic.payloadKey, historicalData: [], rollingCurrentStatistics: rollingStatistics)
            }
    }
    
    func create(req: Request) throws -> EventLoopFuture<DerivedStatisticGroup> {
        struct DerivedStatisticGroupCreateRequestBody: Content, Validatable {
            let title: String
            
            static func validations(_ validations: inout Validations) {
                validations.add("title", as: String.self, is: !.empty)
            }
        }
        
        guard let appIDString = req.parameters.get("appID"),
              let appID = UUID(appIDString) else {
            throw Abort(.badRequest, reason: "Invalid parameter `appID`")
        }
        
        let user = try req.auth.require(User.self)
        let derivedStatisticGroupCreateRequestBody = try req.content.decode(DerivedStatisticGroupCreateRequestBody.self)
        
        let derivedStatisticGroup = DerivedStatisticGroup()
        derivedStatisticGroup.title = derivedStatisticGroupCreateRequestBody.title
        derivedStatisticGroup.$app.id = appID
        
        return derivedStatisticGroup.save(on: req.db).map { derivedStatisticGroup }
    }
    
    func createDerivedStatistic(req: Request) throws -> EventLoopFuture<DerivedStatistic> {
        struct DerivedStatisticCreateRequestBody: Content, Validatable {
            let title: String
            let payloadKey: String
            
            static func validations(_ validations: inout Validations) {
                validations.add("title", as: String.self, is: !.empty)
                validations.add("payloadKey", as: String.self, is: !.empty)
            }
        }
        
        guard let appIDString = req.parameters.get("appID"),
              let appID = UUID(appIDString) else {
            throw Abort(.badRequest, reason: "Invalid parameter `appID`")
        }
        
        guard let derivedStatisticGroupIDString = req.parameters.get("derivedStatisticGroupID"),
              let derivedStatisticGroupID = UUID(derivedStatisticGroupIDString) else {
            throw Abort(.badRequest, reason: "Invalid parameter `derivedStatisticGroupID`")
        }
        
        let user = try req.auth.require(User.self)
        let derivedStatisticCreateRequestBody = try req.content.decode(DerivedStatisticCreateRequestBody.self)
        
        let derivedStatistic = DerivedStatistic()
        derivedStatistic.title = derivedStatisticCreateRequestBody.title
        derivedStatistic.payloadKey = derivedStatisticCreateRequestBody.payloadKey
        derivedStatistic.$derivedStatisticGroup.id = derivedStatisticGroupID
        
        return derivedStatistic.save(on: req.db).map { derivedStatistic }
    }
}
