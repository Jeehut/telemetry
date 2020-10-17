import Vapor
import Fluent


final class Insight: Model, Content {

    static let schema = "insights"
    
    @ID(key: .id)
    var id: UUID?
    
    @Parent(key: "group_id")
    var group: InsightGroup
    
    @Field(key: "order")
    var order: Double?
    
    @Field(key: "title")
    var title: String
    
    @Field(key: "subtitle")
    var subtitle: String?
    
    @Field(key: "signal_type")
    var signalType: String
    
    @Field(key: "unique_user")
    var uniqueUser: Bool
    
    @Field(key: "filters")
    var filters: [String: String]
       
    @Field(key: "rolling_window_size")
    var rollingWindowSize: TimeInterval
    
    @Field(key: "breakdown_key")
    var breakdownKey: String?
    
    // TODO
//    
//    @Children(for: \.$insight)
//    var historicalData: [OldInsightHistoricalData]
}

struct InsightDataTransferObject: Content {
    let id: UUID
    
    let order: Double?
    var title: String
    var subtitle: String?
    
    /// Which signal types are we interested in? If nil, do not filter by signal type
    var signalType: String?
    
    /// If true, only include at the newest signal from each user
    var uniqueUser: Bool
    
    /// Only include signals that match all of these key-values in the payload
    var filters: [String: String]
    
    /// How far to go back to aggregate signals
    var rollingWindowSize: TimeInterval
    
    /// If set, return a breakdown of the values of this payload key
    var breakdownKey: String?
    
    /// Current Live Calculated Data
    let data: [String: Float]
    
    /// When was this DTO calculated?
    let calculatedAt: Date
}
