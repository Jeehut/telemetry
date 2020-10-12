import Fluent
import Vapor

#if os(Linux)
import FoundationNetworking
#endif

func routes(_ app: Application) throws {
    
    app.get { req -> EventLoopFuture<View> in
        struct Index: Codable {
            var title: String
            var description: String
        }

        struct Page: Codable {
            var content: String
        }

        struct Context: Codable {
            var index: Index
            var page: Page
            var additionalData: [String: String] = [:]
        }
        
        struct SignalPostBody: Codable {
            let type: String
            let clientUser: String
            let payload: Dictionary<String, String>?
        }

        return Signal.query(on: req.db)
            .count()
            .flatMap { signalCount in
                Organization.query(on: req.db)
                    .count()
                    .map { orgCount in
                        return (signalCount, orgCount)
                    }
            }
            .flatMap { signalAndOrgCount in
                App.query(on: req.db)
                    .count()
                    .map { appCount in
                        return (signalAndOrgCount.1, appCount, signalAndOrgCount.0)
                    }
            }
            .flatMap { orgAppSignalCount in
                let context = Context(index: .init(title: "Watch your App Grow and Evolve", description: "A Private and Secure Telemetry Service for Your App"),
                                      page: .init(content: "Telemetry is a new service that helps app and web developers improve their product by supplying immediate, accurate telemetry data while users use your app. And the best part: <strong>It's all anonymized so your user's data stays private!"),
                                      additionalData: ["numberOfOrganizations": "\(orgAppSignalCount.0)", "numberOfApps": "\(orgAppSignalCount.1)", "numberOfSignals": "\(orgAppSignalCount.2)"]
                )
                
                
                #if os(Linux)
                // Linux means we're hosted on a server, not in development
                let shouldReportVisits = true
                #else
                let shouldReportVisits = false
                #endif
                
                if shouldReportVisits {
                    let url = URL(string:"https://apptelemetry.io/api/v1/apps/D7AD678E-46F7-4A44-BC32-4B11B90206C3/signals/")!
                    
                    var urlRequest = URLRequest(url: url)
                    urlRequest.httpMethod = "POST"
                    urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
                    
                    let payLoad: [String: String] = [
                        "numberOfOrganizations": "\(orgAppSignalCount.0)",
                        "numberOfApps": "\(orgAppSignalCount.1)",
                        "numberOfSignals": "\(orgAppSignalCount.2)"
                    ]
                    
                    let signalPostBody: SignalPostBody = SignalPostBody(type: "frontPageVisited", clientUser: "\(req.remoteAddress?.description ?? "")", payload: payLoad)
                    
                    urlRequest.httpBody = try! JSONEncoder().encode(signalPostBody)
                    
                    let task = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
                        if let error = error { print(error, data as Any, response as Any) }
                        if let data = data, let dataAsUTF8 = String(data: data, encoding: .utf8) {
                            print(dataAsUTF8)
                        }
                    }
                    task.resume()
                }

                return req.view.render("page", context)
            }


    }

    let apiRoutes = app.grouped("api", "v1")
    try apiRoutes.grouped("users").register(collection: UsersController())
    try apiRoutes.grouped("apps").register(collection: AppController())
    try apiRoutes.grouped("apps", ":appID", "signals").register(collection: SignalsController())
    try apiRoutes.grouped("apps", ":appID", "insightgroups").register(collection: InsightGroupsController())
    try apiRoutes.grouped("apps", ":appID", "insightgroups", ":insightGroupID", "insights").register(collection: InsightsController())
}
