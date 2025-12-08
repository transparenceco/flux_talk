import Fluent
import Vapor

final class Setting: Model, Content {
    static let schema = "settings"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "key")
    var key: String
    
    @Field(key: "value")
    var value: String
    
    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?
    
    init() { }
    
    init(id: UUID? = nil, key: String, value: String) {
        self.id = id
        self.key = key
        self.value = value
    }
}
