import Fluent
import Vapor

final class DerivedStatisticHistoricalData: Model, Content {
    static let schema = "derivedstatistichistoricaldata"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "title")
    var title: String
    
    @Field(key: "statistics")
    var statistics: [String: Int]
    
    @Field(key: "calculated_at")
    var calculatedAt: Date
    
    @Parent(key: "derivedstatistic_id")
    var derivedStatistic: DerivedStatistic
}
