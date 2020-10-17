import Fluent
import Vapor

@available(*, deprecated, message: "Use Insights instead of OldInsights")
final class OldInsightHistoricalData: Model, Content {
    static let schema = "insight_historical_data"
    
    @ID(key: .id)
    var id: UUID?
    
    @Parent(key: "insight_id")
    var insight: OldInsight
    
    @Field(key: "calculated_at")
    var calculatedAt: Date
    
    @Field(key: "data")
    var data: [String: Float]
}
