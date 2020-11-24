import Vapor
import Fluent

enum InsightDisplayMode: String, Codable {
    case number // Deprecated
    case raw
    case barChart
    case lineChart
    case pieChart
}

enum InsightGroupByInterval: String, Codable {
    case hour
    case day
    case week
    case month
}

final class Insight: Model, Content {

    static let schema = "insights"
    
    @ID(key: .id)
    var id: UUID?
    
    @Parent(key: "group_id")
    var group: InsightGroup
    
    /// Insights are ordered by this property
    @Field(key: "order")
    var order: Double?
    
    @Field(key: "title")
    var title: String
    
    @Field(key: "subtitle")
    var subtitle: String?
    
    /// If not nil, only count signals with this type
    @Field(key: "signal_type")
    var signalType: String?
    
    /// Only count one signal per user
    @Field(key: "unique_user")
    var uniqueUser: Bool
    
    /// Each filter key needs to present in the metadata payload and have the specified value for the signal to be counted
    @Field(key: "filters")
    var filters: [String: String]
    
    /// How far back should we look for signals? This should be a negative time interval.
    @Field(key: "rolling_window_size")
    var rollingWindowSize: TimeInterval
    
    /// If not nil, return a breakdown of values in this metadata payload key. Incompatible with groupBy
    @Field(key: "breakdown_key")
    var breakdownKey: String?
    
    /// If not nil, group and count found signals by this time interval. Incompatible with breakdownKey
    @Field(key: "group_by")
    var groupBy: InsightGroupByInterval?
    
    /// What kind of graph should this Insight be displayed as?
    @Field(key: "display_mode")
    var displayMode: InsightDisplayMode
    
    /// Should the insight be displayed as a large banner instead of a tile?
    @Field(key: "is_expanded")
    var isExpanded: Bool
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
    
    /// If set, group and count found signals by this time interval. Incompatible with breakdownKey
    var groupBy: InsightGroupByInterval?
    
    /// How should this insight's data be displayed?
    var displayMode: InsightDisplayMode
    
    /// If true, the insight will be displayed bigger
    var isExpanded: Bool
    
    /// Current Live Calculated Data
    let data: [[String: String]]
    
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
    
    /// If set, group and count found signals by this time interval. Incompatible with breakdownKey
    var groupBy: InsightGroupByInterval?
    
    /// How should this insight's data be displayed?
    var displayMode: InsightDisplayMode
    
    /// If true, the insight will be displayed bigger
    let isExpanded: Bool
    
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
    
    /// If set, group and count found signals by this time interval. Incompatible with breakdownKey
    var groupBy: InsightGroupByInterval?
    
    /// How should this insight's data be displayed?
    let displayMode: InsightDisplayMode
    
    /// If true, the insight will be displayed bigger
    let isExpanded: Bool
}
