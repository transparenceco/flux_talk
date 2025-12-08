import Vapor

protocol AIProvider {
    func chat(message: String, context: [String]) async throws -> String
}

class AIService {
    private let app: Application
    
    init(app: Application) {
        self.app = app
    }
    
    func getProvider(mode: String) -> AIProvider {
        switch mode.lowercased() {
        case "local":
            return LMStudioProvider(app: app)
        case "grok":
            return GrokProvider(app: app)
        case "openai":
            return OpenAIProvider(app: app)
        default:
            return LMStudioProvider(app: app)
        }
    }
}

// LM Studio Provider (OpenAI-compatible local API)
class LMStudioProvider: AIProvider {
    private let app: Application
    private let baseURL = "http://localhost:1234/v1"
    
    init(app: Application) {
        self.app = app
    }
    
    func chat(message: String, context: [String]) async throws -> String {
        let contextString = context.isEmpty ? "" : "\nContext: " + context.joined(separator: "\n")
        let fullMessage = message + contextString
        
        let requestBody = OpenAIChatRequest(
            model: "local-model",
            messages: [OpenAIChatMessage(role: "user", content: fullMessage)],
            temperature: 0.7
        )
        
        let response = try await app.client.post(URI(string: "\(baseURL)/chat/completions")) { req in
            try req.content.encode(requestBody)
        }
        
        let chatResponse = try response.content.decode(OpenAIChatResponse.self)
        return chatResponse.choices.first?.message.content ?? "No response"
    }
}

// Grok Provider
class GrokProvider: AIProvider {
    private let app: Application
    private let baseURL = "https://api.x.ai/v1"
    
    init(app: Application) {
        self.app = app
    }
    
    func chat(message: String, context: [String]) async throws -> String {
        guard let apiKey = Environment.get("GROK_API_KEY") else {
            throw Abort(.internalServerError, reason: "GROK_API_KEY not set")
        }
        
        let contextString = context.isEmpty ? "" : "\nContext: " + context.joined(separator: "\n")
        let fullMessage = message + contextString
        
        let requestBody = OpenAIChatRequest(
            model: "grok-beta",
            messages: [OpenAIChatMessage(role: "user", content: fullMessage)],
            temperature: 0.7
        )
        
        let response = try await app.client.post(URI(string: "\(baseURL)/chat/completions")) { req in
            req.headers.add(name: .authorization, value: "Bearer \(apiKey)")
            try req.content.encode(requestBody)
        }
        
        let chatResponse = try response.content.decode(OpenAIChatResponse.self)
        return chatResponse.choices.first?.message.content ?? "No response"
    }
}

// OpenAI Provider
class OpenAIProvider: AIProvider {
    private let app: Application
    private let baseURL = "https://api.openai.com/v1"
    
    init(app: Application) {
        self.app = app
    }
    
    func chat(message: String, context: [String]) async throws -> String {
        guard let apiKey = Environment.get("OPENAI_API_KEY") else {
            throw Abort(.internalServerError, reason: "OPENAI_API_KEY not set")
        }
        
        let contextString = context.isEmpty ? "" : "\nContext: " + context.joined(separator: "\n")
        let fullMessage = message + contextString
        
        let requestBody = OpenAIChatRequest(
            model: "gpt-4",
            messages: [OpenAIChatMessage(role: "user", content: fullMessage)],
            temperature: 0.7
        )
        
        let response = try await app.client.post(URI(string: "\(baseURL)/chat/completions")) { req in
            req.headers.add(name: .authorization, value: "Bearer \(apiKey)")
            try req.content.encode(requestBody)
        }
        
        let chatResponse = try response.content.decode(OpenAIChatResponse.self)
        return chatResponse.choices.first?.message.content ?? "No response"
    }
}

// OpenAI API Models
struct OpenAIChatRequest: Content {
    let model: String
    let messages: [OpenAIChatMessage]
    let temperature: Double
}

struct OpenAIChatMessage: Content {
    let role: String
    let content: String
}

struct OpenAIChatResponse: Content {
    let choices: [OpenAIChatChoice]
}

struct OpenAIChatChoice: Content {
    let message: OpenAIChatMessage
}
