import Fluent
import Vapor

final class Insight: Model, Content {
    enum InsightType: String, Codable {
        case breakdown
        case count
        case mean
    }
    
    static let schema = "insight"
    
    @ID(key: .id)
    var id: UUID?
    
    @Parent(key: "group_id")
    var group: InsightGroup
    
    @Field(key: "title")
    var title: String
    
    @Field(key: "insight_type")
    var insightType: InsightType
    
    @Field(key: "time_interval")
    var timeInterval: TimeInterval
    
    @Field(key: "configuration")
    var configuration: [String: String]
    
    @Field(key: "order")
    var order: Double?
    
    @Children(for: \.$insight)
    var historicalData: [InsightHistoricalData]
}

struct InsightDataTransferObject: Content {
    let id: UUID
    let title: String
    let insightType: Insight.InsightType
    let timeInterval: TimeInterval
    let configuration: [String: String]
    let data: [String: Float]
    let calculatedAt: Date
}
