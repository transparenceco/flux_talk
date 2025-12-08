import Foundation

struct Message: Codable, Identifiable {
    let id: UUID
    let role: String
    let content: String
    let provider: String
    let createdAt: Date?
    
    var isUser: Bool {
        role == "user"
    }
}

struct ChatRequest: Codable {
    let message: String
    let useContext: Bool?
}

struct ChatResponse: Codable {
    let message: String
    let provider: String
    let messageId: UUID
}

struct MessagesResponse: Codable {
    let messages: [Message]
}

struct Setting: Codable {
    let key: String
    let value: String
}

enum AIMode: String, CaseIterable {
    case local = "local"
    case grok = "grok"
    case openai = "openai"
    
    var displayName: String {
        switch self {
        case .local: return "Local (LM Studio)"
        case .grok: return "Grok (xAI)"
        case .openai: return "OpenAI"
        }
    }
}
