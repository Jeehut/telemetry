import Fluent
import Vapor

final class DerivedStatistic: Model, Content {
    static let schema = "derivedstatistic"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "title")
    var title: String
    
    @Field(key: "payloadkey")
    var payloadKey: String

    @Parent(key: "derivedstatisticgroup_id")
    var derivedStatisticGroup: DerivedStatisticGroup
    
    @Children(for: \.$derivedStatistic)
    var historicalData: [DerivedStatisticHistoricalData]
}

struct DerivedStatisticDataTransferObject: Content {
    var id: UUID
    var title: String
    var payloadKey: String
    var historicalData: [DerivedStatisticHistoricalData]
    
    // This is not a field, and should be calculated at retrieval time
    var rollingCurrentStatistics: [String: Int]
}

