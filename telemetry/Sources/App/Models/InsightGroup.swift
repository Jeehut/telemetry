import Fluent
import Vapor

final class InsightGroup: Model, Content {
    static let schema = "insight_group"
    
    @ID(key: .id)
    var id: UUID?
    
    @Parent(key: "app_id")
    var app: App
    
    @Field(key: "title")
    var title: String
    
    @Children(for: \.$group)
    var insights: [Insight]
}
