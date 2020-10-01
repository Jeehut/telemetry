import Vapor
import Fluent

extension InsightsController {
    func getBreakdown(insight: Insight, conditions: [InsightFilterCondition], calculatedAtDate: Date = Date(), req: Request, appID: UUID) -> EventLoopFuture<InsightDataTransferObject> {

        let earlierDate = Date(timeInterval: insight.timeInterval, since: calculatedAtDate)
        
        return Signal.query(on: req.db)
            .filter(\.$app.$id == appID)
            .filter(\.$receivedAt > earlierDate)
            .filter(\.$receivedAt < calculatedAtDate)
            .sort(\.$receivedAt, .descending)
            .all()
            .map { signals in
                (insight, signals)
            }
            .map { insightTuple -> InsightDataTransferObject in
                let insight = insightTuple.0
                let signals = insightTuple.1
                let payloadKey = insight.configuration["breakdown.payloadKey"] ?? "no payload key!"
                
                var breakdownStatistics: [String: Float] = [:]
                var knownUserIdentifiers: [String] = []
                
                for signal in signals {
                    guard let payloadDict = signal.payload, let payloadContent = payloadDict[payloadKey] else { continue }
                    
                    if conditions.contains(.uniqueUser) {
                        guard !knownUserIdentifiers.contains(signal.clientUser) else { continue }
                    }
                    
                    let currentAmountInStatistics = breakdownStatistics[payloadContent, default: 0]
                    breakdownStatistics[payloadContent] = currentAmountInStatistics + 1
                    knownUserIdentifiers.append(signal.clientUser)
                }
                
                return InsightDataTransferObject(
                    id: insight.id!,
                    title: insight.title,
                    insightType: insight.insightType,
                    timeInterval: insight.timeInterval,
                    configuration: insight.configuration,
                    data: breakdownStatistics,
                    calculatedAt: calculatedAtDate)
            }
    }
}
