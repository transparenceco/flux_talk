import Foundation

@MainActor
class APIService {
    static let shared = APIService()
    
    // Default to localhost - users should configure this to their server IP
    var baseURL = "http://localhost:8080"
    
    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()
    
    private let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }()
    
    // Send a chat message
    func sendMessage(_ message: String, useContext: Bool = true) async throws -> ChatResponse {
        let url = URL(string: "\(baseURL)/api/chat")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let chatRequest = ChatRequest(message: message, useContext: useContext)
        request.httpBody = try encoder.encode(chatRequest)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        return try decoder.decode(ChatResponse.self, from: data)
    }
    
    // Get chat history
    func getChatHistory() async throws -> [Message] {
        let url = URL(string: "\(baseURL)/api/chat/history")!
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try decoder.decode(MessagesResponse.self, from: data)
        return response.messages
    }
    
    // Clear chat history
    func clearChatHistory() async throws {
        let url = URL(string: "\(baseURL)/api/chat/history")!
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        _ = try await URLSession.shared.data(for: request)
    }
    
    // Get settings
    func getSettings() async throws -> [Setting] {
        let url = URL(string: "\(baseURL)/api/settings")!
        let (data, _) = try await URLSession.shared.data(from: url)
        return try decoder.decode([Setting].self, from: data)
    }
    
    // Get specific setting
    func getSetting(key: String) async throws -> Setting {
        let url = URL(string: "\(baseURL)/api/settings/\(key)")!
        let (data, _) = try await URLSession.shared.data(from: url)
        return try decoder.decode(Setting.self, from: data)
    }
    
    // Set a setting
    func setSetting(key: String, value: String) async throws -> Setting {
        let url = URL(string: "\(baseURL)/api/settings")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let setting = Setting(key: key, value: value)
        request.httpBody = try encoder.encode(setting)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        return try decoder.decode(Setting.self, from: data)
    }
}
