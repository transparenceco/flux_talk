import Vapor
import Fluent

struct ChatController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let chat = routes.grouped("api", "chat")
        chat.post(use: sendMessage)
        chat.get("history", use: getHistory)
        chat.delete("history", use: clearHistory)
    }
    
    func sendMessage(req: Request) async throws -> ChatResponse {
        let chatRequest = try req.content.decode(ChatRequest.self)
        
        // Get current AI mode from settings
        let modeSetting = try await Setting.query(on: req.db)
            .filter(\.$key == "ai_mode")
            .first()
        let mode = modeSetting?.value ?? "local"
        
        // Get AI settings for the current mode
        let aiService = AIService(app: req.application)
        let aiSettings = try await aiService.getSettings(on: req.db, for: mode)
        
        // Get context from vector DB if requested
        var context: [String] = []
        if chatRequest.useContext ?? true {
            let vectorDB = VectorDBService(app: req.application)
            let results = try await vectorDB.search(query: chatRequest.message, limit: 3)
            context = results.map { $0.content }
        }
        
        // Get AI response
        let provider = aiService.getProvider(mode: mode)
        let response = try await provider.chat(message: chatRequest.message, context: context, settings: aiSettings)
        
        // Save user message
        let userMessage = Message(role: "user", content: chatRequest.message, provider: mode)
        try await userMessage.save(on: req.db)
        
        // Save assistant message
        let assistantMessage = Message(role: "assistant", content: response, provider: mode)
        try await assistantMessage.save(on: req.db)
        
        return ChatResponse(
            message: response,
            provider: mode,
            messageId: assistantMessage.id!
        )
    }
    
    func getHistory(req: Request) async throws -> MessagesResponse {
        let messages = try await Message.query(on: req.db)
            .sort(\.$createdAt, .ascending)
            .all()
        
        let dtos = messages.map { msg in
            MessageDTO(
                id: msg.id!,
                role: msg.role,
                content: msg.content,
                provider: msg.provider,
                createdAt: msg.createdAt
            )
        }
        
        return MessagesResponse(messages: dtos)
    }
    
    func clearHistory(req: Request) async throws -> HTTPStatus {
        try await Message.query(on: req.db).delete()
        return .noContent
    }
}
