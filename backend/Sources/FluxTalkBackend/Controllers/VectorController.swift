import Vapor

struct VectorController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let vector = routes.grouped("api", "vector")
        vector.post("add", use: addContent)
        vector.post("search", use: search)
    }
    
    func addContent(req: Request) async throws -> HTTPStatus {
        let addRequest = try req.content.decode(VectorAddRequest.self)
        let vectorDB = VectorDBService(app: req.application)
        
        do {
            let id = UUID().uuidString
            try await vectorDB.addContent(
                id: id,
                content: addRequest.content,
                metadata: addRequest.metadata
            )
            return .created
        } catch {
            req.logger.error("Failed to add content to vector DB: \(error)")
            throw Abort(.internalServerError, reason: "Failed to add content to vector database: \(error.localizedDescription)")
        }
    }
    
    func search(req: Request) async throws -> VectorSearchResponse {
        let searchRequest = try req.content.decode(VectorSearchRequest.self)
        let vectorDB = VectorDBService(app: req.application)
        
        do {
            let results = try await vectorDB.search(
                query: searchRequest.query,
                limit: searchRequest.limit ?? 5
            )
            return VectorSearchResponse(results: results)
        } catch {
            req.logger.error("Failed to search vector DB: \(error)")
            throw Abort(.internalServerError, reason: "Failed to search vector database: \(error.localizedDescription)")
        }
    }
}
