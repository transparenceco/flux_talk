import Vapor

struct ChatRequest: Content {
    let message: String
    let useContext: Bool?
}

struct ChatResponse: Content {
    let message: String
    let provider: String
    let messageId: UUID
}

struct MessagesResponse: Content {
    let messages: [MessageDTO]
}

struct MessageDTO: Content {
    let id: UUID
    let role: String
    let content: String
    let provider: String
    let createdAt: Date?
}

struct SettingDTO: Content {
    let key: String
    let value: String
}

struct VectorAddRequest: Content {
    let content: String
    let metadata: [String: String]?
}

struct VectorSearchRequest: Content {
    let query: String
    let limit: Int?
}

struct VectorSearchResponse: Content {
    let results: [VectorResult]
}

struct VectorResult: Content {
    let content: String
    let distance: Double
    let metadata: [String: String]?
}
