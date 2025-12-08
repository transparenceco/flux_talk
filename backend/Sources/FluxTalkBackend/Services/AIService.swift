import Vapor
import Fluent

protocol AIProvider {
    func chat(message: String, context: [String], settings: AISettings) async throws -> String
}

struct AISettings {
    let temperature: Double
    let model: String
    let apiKey: String?
    let baseURL: String?
    
    static let `default` = AISettings(
        temperature: 0.7,
        model: "default",
        apiKey: nil,
        baseURL: nil
    )
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
    
    func getSettings(on db: Database, for mode: String) async throws -> AISettings {
        let temperature = try await getSetting(db: db, key: "temperature") ?? "0.7"
        let model = try await getSetting(db: db, key: "\(mode)_model") ?? getDefaultModel(for: mode)
        let apiKey = try await getSetting(db: db, key: "\(mode)_api_key")
        let baseURL = try await getSetting(db: db, key: "\(mode)_base_url")
        
        return AISettings(
            temperature: Double(temperature) ?? 0.7,
            model: model,
            apiKey: apiKey,
            baseURL: baseURL
        )
    }
    
    private func getSetting(db: Database, key: String) async throws -> String? {
        return try await Setting.query(on: db)
            .filter(\.$key == key)
            .first()?.value
    }
    
    private func getDefaultModel(for mode: String) -> String {
        switch mode.lowercased() {
        case "local":
            return "local-model"
        case "grok":
            return "grok-beta"
        case "openai":
            return "gpt-4"
        default:
            return "default"
        }
    }
}

// LM Studio Provider (OpenAI-compatible local API)
class LMStudioProvider: AIProvider {
    private let app: Application
    
    init(app: Application) {
        self.app = app
    }
    
    func chat(message: String, context: [String], settings: AISettings) async throws -> String {
        let baseURL = settings.baseURL ?? "http://localhost:1234/v1"
        let contextString = context.isEmpty ? "" : "\nContext: " + context.joined(separator: "\n")
        let fullMessage = message + contextString
        
        let requestBody = OpenAIChatRequest(
            model: settings.model,
            messages: [OpenAIChatMessage(role: "user", content: fullMessage)],
            temperature: settings.temperature
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
    
    init(app: Application) {
        self.app = app
    }
    
    func chat(message: String, context: [String], settings: AISettings) async throws -> String {
        let baseURL = settings.baseURL ?? "https://api.x.ai/v1"
        let apiKey = settings.apiKey ?? Environment.get("GROK_API_KEY")
        
        guard let key = apiKey else {
            throw Abort(.internalServerError, reason: "GROK_API_KEY not set in settings or environment")
        }
        
        let contextString = context.isEmpty ? "" : "\nContext: " + context.joined(separator: "\n")
        let fullMessage = message + contextString
        
        let requestBody = OpenAIChatRequest(
            model: settings.model,
            messages: [OpenAIChatMessage(role: "user", content: fullMessage)],
            temperature: settings.temperature
        )
        
        let response = try await app.client.post(URI(string: "\(baseURL)/chat/completions")) { req in
            req.headers.add(name: .authorization, value: "Bearer \(key)")
            try req.content.encode(requestBody)
        }
        
        let chatResponse = try response.content.decode(OpenAIChatResponse.self)
        return chatResponse.choices.first?.message.content ?? "No response"
    }
}

// OpenAI Provider
class OpenAIProvider: AIProvider {
    private let app: Application
    
    init(app: Application) {
        self.app = app
    }
    
    func chat(message: String, context: [String], settings: AISettings) async throws -> String {
        let baseURL = settings.baseURL ?? "https://api.openai.com/v1"
        let apiKey = settings.apiKey ?? Environment.get("OPENAI_API_KEY")
        
        guard let key = apiKey else {
            throw Abort(.internalServerError, reason: "OPENAI_API_KEY not set in settings or environment")
        }
        
        let contextString = context.isEmpty ? "" : "\nContext: " + context.joined(separator: "\n")
        let fullMessage = message + contextString
        
        let requestBody = OpenAIChatRequest(
            model: settings.model,
            messages: [OpenAIChatMessage(role: "user", content: fullMessage)],
            temperature: settings.temperature
        )
        
        let response = try await app.client.post(URI(string: "\(baseURL)/chat/completions")) { req in
            req.headers.add(name: .authorization, value: "Bearer \(key)")
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
