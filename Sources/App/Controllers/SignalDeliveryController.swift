import Fluent
import Vapor


struct SignalDeliveryController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let signals = routes.grouped("")
        signals.post(":appID", use: postSignal)
    }
    
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
    
    func postSignal(req: Request) throws -> EventLoopFuture<Signal> {
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
