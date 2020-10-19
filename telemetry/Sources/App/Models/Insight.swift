import Vapor
import Fluent

enum InsightDisplayMode: String, Codable {
    case number
    case barChart
    case lineChart
    case pieChart
}

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
    var signalType: String?
    
    @Field(key: "unique_user")
    var uniqueUser: Bool
    
    @Field(key: "filters")
    var filters: [String: String]
       
    @Field(key: "rolling_window_size")
    var rollingWindowSize: TimeInterval
    
    @Field(key: "breakdown_key")
    var breakdownKey: String?
    
    @Field(key: "display_mode")
    var displayMode: InsightDisplayMode
    
    // TODO
//    
//    @Children(for: \.$insight)
//    var historicalData: [OldInsightHistoricalData]
}

struct InsightDataTransferObject: Content {
    let id: UUID
    
    let order: Double?
    let title: String
    let subtitle: String?
    
    /// Which signal types are we interested in? If nil, do not filter by signal type
    let signalType: String?
    
    /// If true, only include at the newest signal from each user
    let uniqueUser: Bool
    
    /// Only include signals that match all of these key-values in the payload
    let filters: [String: String]
    
    /// How far to go back to aggregate signals
    let rollingWindowSize: TimeInterval
    
    /// If set, return a breakdown of the values of this payload key
    let breakdownKey: String?
    
    /// How should this insight's data be displayed?
    var displayMode: InsightDisplayMode
    
    /// Current Live Calculated Data
    let data: [[String: Double]]
    
    /// When was this DTO calculated?
    let calculatedAt: Date
}

struct InsightCreateRequestBody: Content, Validatable {
    let order: Double?
    let title: String
    let subtitle: String?
    
    /// Which signal types are we interested in? If nil, do not filter by signal type
    let signalType: String?
    
    /// If true, only include at the newest signal from each user
    let uniqueUser: Bool
    
    /// Only include signals that match all of these key-values in the payload
    let filters: [String: String]
    
    /// How far to go back to aggregate signals
    let rollingWindowSize: TimeInterval
    
    /// If set, return a breakdown of the values of this payload key
    let breakdownKey: String?
    
    /// How should this insight's data be displayed?
    var displayMode: InsightDisplayMode
    
    static func validations(_ validations: inout Validations) {
        // TOOD: More validations
        validations.add("title", as: String.self, is: !.empty)
    }
}

struct InsightUpdateRequestBody: Content {
    let groupID: UUID
    let order: Double?
    let title: String
    let subtitle: String?
    
    /// Which signal types are we interested in? If nil, do not filter by signal type
    let signalType: String?
    
    /// If true, only include at the newest signal from each user
    let uniqueUser: Bool
    
    /// Only include signals that match all of these key-values in the payload
    let filters: [String: String]
    
    /// How far to go back to aggregate signals
    let rollingWindowSize: TimeInterval
    
    /// If set, return a breakdown of the values of this payload key
    let breakdownKey: String?
    
    /// How should this insight's data be displayed?
    var displayMode: InsightDisplayMode
}
