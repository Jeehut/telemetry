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
    
    @Children(for: \.$derivedStatisticGroup)
    var derivedStatistics: [DerivedStatistic]
}

struct DerivedStatisticGroupDataTransferObject: Content {
    let id: UUID
    let app: [String: String]
    let title: String
    let derivedStatistics: [DerivedStatisticDataTransferObject]
}
