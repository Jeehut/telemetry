import Fluent
import Vapor

final class UserCountGroup: Model, Content {
    static let schema = "usercount_groups"
    
    @ID(key: .id)
    var id: UUID?
    
    @Parent(key: "app_id")
    var app: App
    
    @Field(key: "title")
    var title: String
    
    @Field(key: "time_interval")
    var timeInterval: TimeInterval
    
    @Children(for: \.$userCountGroup)
    var data: [UserCount]
}
