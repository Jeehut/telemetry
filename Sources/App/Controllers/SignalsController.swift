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
        // TODO: Only return signals for this user's org
        
        return Signal.query(on: req.db)
            .filter(\.$app.$id == appID)
            .all()
    }
    
    func postSignal(req: Request) throws -> EventLoopFuture<Signal> {
        
        struct SignalDeliveryResponse: Content {
            let status: String
        }
        
        struct SignalPostBody: Content {
            let type: String
            let clientUser: String
            let payload: Dictionary<String, String>?
            
            func makeSignal() throws -> Signal {
                let signal = Signal()
                signal.clientUser = try Bcrypt.hash(self.clientUser)
                signal.type = self.type
                signal.payload = self.payload
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
