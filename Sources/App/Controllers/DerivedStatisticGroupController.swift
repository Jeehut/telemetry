import Fluent
import Vapor


struct DerivedStatisticGroupController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let derivedStatisticGroups = routes.grouped(UserToken.authenticator())
        derivedStatisticGroups.get(use: getAll)
        derivedStatisticGroups.post(use: create)
        derivedStatisticGroups.post(":derivedStatisticGroupID", "derivedstatistics", use: createDerivedStatistic)
    }
    
    func getAll(req: Request) throws -> EventLoopFuture<[DerivedStatisticGroupDataTransferObject]> {
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
            .mapEach { derivedStatisticGroup -> DerivedStatisticGroupDataTransferObject in
                // Retrieve the value at the current time
                let laterDate = Date()
                let earlierDate = Date(timeInterval: -3600*24, since: laterDate)
                
                let dto = DerivedStatisticGroupDataTransferObject(
                    id: derivedStatisticGroup.id!,
                    app: ["id": derivedStatisticGroup.$app.id.uuidString],
                    title: derivedStatisticGroup.title,
                    derivedStatistics: derivedStatisticGroup.derivedStatistics.map {
                        DerivedStatisticDataTransferObject(
                            id: $0.id!,
                            title: $0.title,
                            payloadKey: $0.payloadKey,
                            historicalData: [],
                            rollingCurrentStatistics: [:]
                        )
                    }
                )
                return dto
                
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
