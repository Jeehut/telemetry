import Vapor
import Fluent

extension OldInsightsController {
    func getCount(insight: OldInsight, conditions: [OldInsightFilterCondition], calculatedAtDate: Date = Date(), req: Request, appID: UUID) -> EventLoopFuture<OldInsightDataTransferObject> {
        
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
            .map { insightTuple -> OldInsightDataTransferObject in
                let insight = insightTuple.0
                let signals = insightTuple.1
                
                var userCount: Float = 0
                var knownUserIdentifiers: [String] = []
                
                for signal in signals {
                    if conditions.contains(.uniqueUser) {
                        guard !knownUserIdentifiers.contains(signal.clientUser) else { continue }
                    }
                    
                    // check if all conditions apply to the current signal
                    var shouldCountSignal = true
                    for condition in conditions {
                        switch condition {
                        case .uniqueUser:
                            break
                        case .keywordEquals(keyword: let keyword, targetValue: let targetValue):
                            // If an "equals" condition is not met, the signal should net be counted
                            if signal.payload?[keyword] != targetValue {
                                shouldCountSignal = false
                                continue
                            }
                        }
                    }
                    
                    // If the conditions have decreed that a signal shall not be counted, continue
                    if !shouldCountSignal {
                        continue
                    }
                    
                    userCount += 1
                    knownUserIdentifiers.append(signal.clientUser)
                }
                
                return OldInsightDataTransferObject(
                    id: insight.id!,
                    title: insight.title,
                    insightType: insight.insightType,
                    timeInterval: insight.timeInterval,
                    configuration: insight.configuration,
                    data: ["count": userCount],
                    calculatedAt: calculatedAtDate)
            }
    }
}
