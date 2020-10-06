import Fluent
import Vapor

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

                return req.view.render("page", context)
            }


    }

    let apiRoutes = app.grouped("api", "v1")
    try apiRoutes.grouped("users").register(collection: RegistrationContoller())
    try apiRoutes.grouped("apps").register(collection: AppController())
    try apiRoutes.grouped("apps", ":appID", "signals").register(collection: SignalsController())
    try apiRoutes.grouped("apps", ":appID", "insightgroups").register(collection: InsightGroupsController())
    try apiRoutes.grouped("apps", ":appID", "insightgroups", ":insightGroupID", "insights").register(collection: InsightsController())
}
