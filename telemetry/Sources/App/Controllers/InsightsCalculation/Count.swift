import Vapor
import Fluent

extension InsightsController {
    func getCount(insight: Insight, req: Request, appID: UUID) -> EventLoopFuture<InsightDataTransferObject> {
        
        let laterDate = Date()
        let earlierDate = Date(timeInterval: -3600*24, since: laterDate)
        
        return Signal.query(on: req.db)
            .filter(\.$app.$id == appID)
            .filter(\.$receivedAt > earlierDate)
            .filter(\.$receivedAt < laterDate)
            .sort(\.$receivedAt, .descending)
            .all()
            .map { signals in
                (insight, signals)
            }
            .map { insightTuple -> InsightDataTransferObject in
                let insight = insightTuple.0
                let signals = insightTuple.1
                
                var userCount: Float = 0
                var knownUserIdentifiers: [String] = []
                
                for signal in signals {
                    guard !knownUserIdentifiers.contains(signal.clientUser) else { continue }
                    
                    userCount += 1
                    knownUserIdentifiers.append(signal.clientUser)
                }
                
                return InsightDataTransferObject(
                    id: insight.id!,
                    title: insight.title,
                    insightType: insight.insightType,
                    timeInterval: insight.timeInterval,
                    configuration: insight.configuration,
                    data: ["count": userCount],
                    calculatedAt: Date())
            }
    }
}
