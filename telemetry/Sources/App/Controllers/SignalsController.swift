import Fluent
import Vapor


struct SignalsController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let signals = routes.grouped(UserToken.authenticator())
        signals.get(use: getSignals)
        signals.post(use: postSignal)
    }
    
    
    func getSignals(req: Request) throws -> EventLoopFuture<[Signal]> {
        guard let appIDString = req.parameters.get("appID"),
              let appID = UUID(appIDString) else {
            throw Abort(.badRequest, reason: "Invalid parameter `appID`")
        }
        
        let user = try req.auth.require(User.self)
        // TODO: Filter for user's org's apps
        
        return Signal.query(on: req.db)
            .filter(\.$app.$id == appID)
            .sort(\.$receivedAt, .descending)
            .limit(20)
            .all()
    }
    
    func postSignal(req: Request) throws -> EventLoopFuture<Signal> {
        // This function does not check for logged in user,
        // because signals posted don't have user ID.
        // Instead, we rely on the App ID as a shared secret
        
        struct SignalDeliveryResponse: Content {
            let status: String
        }
        
        struct SignalPostBody: Content {
            let type: String
            let clientUser: String
            let payload: Dictionary<String, String>?
            
            func makeSignal() throws -> Signal {
                let signal = Signal()
                signal.clientUser = self.clientUser // TODO: This hash returns a new value each time WTF try Bcrypt.hash(self.clientUser)
                signal.type = self.type
                
                let resolvedPayload = self.payload ?? [:]
                signal.payload = resolvedPayload.merging(["signalType": self.type, "signalClientUser": self.clientUser], uniquingKeysWith: { (_, last) in last })
                return signal
            }
        }
        
        guard let appIDString = req.parameters.get("appID"),
            let appID = UUID(appIDString) else {
            throw Abort(.badRequest, reason: "Invalid parameter `appID`")
        }
        
        let signalPostBody = try req.content.decode(SignalPostBody.self)
        let signal = try signalPostBody.makeSignal()
        signal.$app.id = appID
        return signal.save(on: req.db).map { signal }
    }
}
