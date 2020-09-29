import Fluent
import Vapor

final class Insight: Model, Content {
    enum InsightType: String, Codable {
        case breakdown
        case mean
    }
    
    static let schema = "insight"
    
    @ID(key: .id)
    var id: UUID?
    
    @Parent(key: "group_id")
    var group: InsightGroup
    
    @Field(key: "title")
    var title: String
    
    // TODO: This should be a database backed enum,
    //       see https://docs.vapor.codes/4.0/fluent/model/#enum
    @Field(key: "insight_type")
    var insightType: InsightType
    
    @Field(key: "time_interval")
    var timeInterval: TimeInterval
    
    @Field(key: "configuration")
    var configuration: [String: String]
    
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
