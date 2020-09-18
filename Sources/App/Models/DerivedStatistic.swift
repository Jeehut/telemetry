import Fluent
import Vapor

final class DerivedStatistic: Model, Content {
    static let schema = "derivedstatistic"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "title")
    var title: String

    @Parent(key: "derivedstatisticgroup_id")
    var derivedStatisticGroup: DerivedStatisticGroup
    
    @Children(for: \.$derivedStatistic)
    var historiclData: [DerivedStatisticHistoricalData]
}
