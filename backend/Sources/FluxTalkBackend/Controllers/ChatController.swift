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
            do {
                let vectorDB = VectorDBService(app: req.application)
                let results = try await vectorDB.search(query: chatRequest.message, limit: 3)
                context = results.map { $0.content }
                if !context.isEmpty {
                    req.logger.info("Found \(context.count) vector context results")
                }
            } catch {
                // Vector DB might not be available, continue without context
                req.logger.warning("Vector DB search failed: \(error)")
            }
        }
        
        // Get recent chat history for context (last 10 messages for better context)
        let recentMessages = try await Message.query(on: req.db)
            .sort(\.$createdAt, .descending)
            .limit(10)
            .all()
        let history = recentMessages.reversed().map { msg in
            "\(msg.role): \(msg.content)"
        }
        
        // Get AI response with error handling
        let provider = aiService.getProvider(mode: mode)
        let response: String
        do {
            response = try await provider.chat(message: chatRequest.message, context: context, history: history, settings: aiSettings)
        } catch {
            req.logger.error("AI service failed for mode '\(mode)': \(error)")
            // Return a fallback response
            response = "I'm sorry, but I'm currently unable to connect to the AI service (\(mode)). Please check that the service is running and properly configured. Error: \(error.localizedDescription)"
        }
        
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
