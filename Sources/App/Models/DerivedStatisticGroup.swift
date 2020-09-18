import Fluent
import Vapor

final class DerivedStatisticGroup: Model, Content {
    static let schema = "derivedstatisticgroup"
    
    @ID(key: .id)
    var id: UUID?
    
    @Parent(key: "app_id")
    var app: App
    
    @Field(key: "title")
    var title: String
    
    // rollingCurrentStatistics is calculated live
    
    @Children(for: \.$derivedStatisticGroup)
    var derivedStatistics: [DerivedStatistic]
}
