import Vapor

class VectorDBService {
    private let app: Application
    private let chromaURL = "http://localhost:8000"
    private let collectionName = "flux_talk_context"
    
    init(app: Application) {
        self.app = app
    }
    
    // Initialize collection if needed
    func ensureCollection() async throws {
        let response = try await app.client.post(URI(string: "\(chromaURL)/api/v1/collections")) { req in
            try req.content.encode([
                "name": collectionName,
                "metadata": ["description": "Flux Talk context storage"]
            ])
        }
        // Ignore if collection already exists (409 conflict)
    }
    
    // Add content to vector DB
    func addContent(id: String, content: String, metadata: [String: String]?) async throws {
        let embedding = try await generateEmbedding(text: content)
        
        let requestBody: [String: Any] = [
            "ids": [id],
            "embeddings": [embedding],
            "documents": [content],
            "metadatas": [metadata ?? [:]]
        ]
        
        _ = try await app.client.post(URI(string: "\(chromaURL)/api/v1/collections/\(collectionName)/add")) { req in
            try req.content.encode(requestBody, as: .json)
        }
    }
    
    // Search for relevant context
    func search(query: String, limit: Int = 3) async throws -> [VectorResult] {
        let embedding = try await generateEmbedding(text: query)
        
        let requestBody: [String: Any] = [
            "query_embeddings": [embedding],
            "n_results": limit
        ]
        
        let response = try await app.client.post(URI(string: "\(chromaURL)/api/v1/collections/\(collectionName)/query")) { req in
            try req.content.encode(requestBody, as: .json)
        }
        
        let searchResponse = try response.content.decode(ChromaSearchResponse.self)
        
        var results: [VectorResult] = []
        if let documents = searchResponse.documents?.first,
           let distances = searchResponse.distances?.first,
           let metadatas = searchResponse.metadatas?.first {
            for i in 0..<documents.count {
                results.append(VectorResult(
                    content: documents[i],
                    distance: distances[i],
                    metadata: metadatas[i] as? [String: String]
                ))
            }
        }
        
        return results
    }
    
    // Simple embedding generation (using local LM Studio or a simple hash for MVP)
    private func generateEmbedding(text: String) async throws -> [Double] {
        // For MVP, we'll try to use LM Studio's embedding endpoint
        // If not available, fall back to a simple word-based embedding
        do {
            let requestBody = ["input": text, "model": "text-embedding-ada-002"]
            let response = try await app.client.post(URI(string: "http://localhost:1234/v1/embeddings")) { req in
                try req.content.encode(requestBody)
            }
            let embeddingResponse = try response.content.decode(EmbeddingResponse.self)
            return embeddingResponse.data.first?.embedding ?? generateSimpleEmbedding(text: text)
        } catch {
            // Fallback to simple embedding
            return generateSimpleEmbedding(text: text)
        }
    }
    
    // Simple fallback embedding based on word hashing (for MVP)
    private func generateSimpleEmbedding(text: String) -> [Double] {
        let words = text.lowercased().components(separatedBy: .whitespacesAndNewlines)
        var embedding = [Double](repeating: 0.0, count: 384) // Standard embedding size
        
        for (index, word) in words.enumerated() {
            let hash = abs(word.hashValue)
            let position = hash % embedding.count
            embedding[position] += 1.0 / Double(index + 1)
        }
        
        // Normalize
        let magnitude = sqrt(embedding.reduce(0.0) { $0 + $1 * $1 })
        if magnitude > 0 {
            embedding = embedding.map { $0 / magnitude }
        }
        
        return embedding
    }
}

struct ChromaSearchResponse: Content {
    let ids: [[String]]?
    let documents: [[String]]?
    let distances: [[Double]]?
    let metadatas: [[Any]]?
}

struct EmbeddingResponse: Content {
    let data: [EmbeddingData]
}

struct EmbeddingData: Content {
    let embedding: [Double]
}
