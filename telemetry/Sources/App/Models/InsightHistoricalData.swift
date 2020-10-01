import Fluent
import Vapor

final class InsightHistoricalData: Model, Content {
    static let schema = "insight_historical_data"
    
    @ID(key: .id)
    var id: UUID?
    
    @Parent(key: "insight_id")
    var insight: Insight
    
    @Field(key: "calculated_at")
    var calculatedAt: Date
    
    @Field(key: "data")
    var data: [String: Float]
}
