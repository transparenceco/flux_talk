import Fluent
import Vapor

final class Message: Model, Content {
    static let schema = "messages"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "role")
    var role: String // "user" or "assistant"
    
    @Field(key: "content")
    var content: String
    
    @Field(key: "provider")
    var provider: String // "local", "grok", "openai"
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    init() { }
    
    init(id: UUID? = nil, role: String, content: String, provider: String) {
        self.id = id
        self.role = role
        self.content = content
        self.provider = provider
    }
}
