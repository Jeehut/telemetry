import Fluent
import Vapor

#if os(Linux)
import FoundationNetworking
#endif

func routes(_ app: Application) throws {
    let apiRoutes = app.grouped("api", "v1")
    
    try apiRoutes.grouped("contexts").register(collection: ContextsController())
    try apiRoutes.grouped("users").register(collection: UsersController())
    try apiRoutes.grouped("apps").register(collection: AppController())
    try apiRoutes.grouped("apps", ":appID", "signals").register(collection: SignalsController())
    try apiRoutes.grouped("apps", ":appID", "insightgroups").register(collection: InsightGroupsController())
    try apiRoutes.grouped("apps", ":appID", "insightgroups", ":insightGroupID", "insights").register(collection: InsightsController())
    try apiRoutes.grouped("apps", ":appID", "lexicon").register(collection: LexiconController())
    try apiRoutes.grouped("betarequests").register(collection: BetaRequestEmailsController())
}
