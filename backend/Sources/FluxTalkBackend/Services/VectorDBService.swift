import Vapor

class VectorDBService {
    private let app: Application
    private let chromaURL = "http://127.0.0.1:8000"
    private let collectionName = "flux_talk_context"
    
    init(app: Application) {
        self.app = app
    }
    
    // Initialize collection if needed
    func ensureCollection() async throws {
        struct CollectionRequest: Content {
            let name: String
            let metadata: [String: String]?
        }
        
        let collectionReq = CollectionRequest(
            name: collectionName,
            metadata: ["description": "Flux Talk context storage"]
        )
        
        do {
            _ = try await app.client.post(
                URI(string: "\(chromaURL)/api/v2/collections"),
                headers: [:],
                content: collectionReq
            )
        } catch {
            // Collection might already exist, try to get it
            _ = try? await app.client.get(
                URI(string: "\(chromaURL)/api/v2/collections/\(collectionName)")
            )
        }
    }
    
    // Add content to vector DB
    func addContent(id: String, content: String, metadata: [String: String]?) async throws {
        let embedding = try await generateEmbedding(text: content)
        
        struct AddRequest: Content {
            let ids: [String]
            let embeddings: [[Double]]
            let documents: [String]
            let metadatas: [[String: String]]
        }
        
        let requestBody = AddRequest(
            ids: [id],
            embeddings: [embedding],
            documents: [content],
            metadatas: [metadata ?? [:]]
        )
        
        do {
            _ = try await app.client.post(
                URI(string: "\(chromaURL)/api/v2/collections/\(collectionName)/add")
            ) { req in
                try req.content.encode(requestBody)
            }
        } catch {
            throw error
        }
    }
    
    // Search for relevant context
    func search(query: String, limit: Int = 3) async throws -> [VectorResult] {
        let embedding = try await generateEmbedding(text: query)
        
        struct SearchRequest: Content {
            let query_embeddings: [[Double]]
            let n_results: Int
        }
        
        let requestBody = SearchRequest(
            query_embeddings: [embedding],
            n_results: limit
        )
        
        do {
            let response = try await app.client.post(
                URI(string: "\(chromaURL)/api/v2/collections/\(collectionName)/query")
            ) { req in
                try req.content.encode(requestBody)
            }
            
            let searchResponse = try response.content.decode(ChromaSearchResponse.self)
            
            var results: [VectorResult] = []
            if let documents = searchResponse.documents?.first,
               let distances = searchResponse.distances?.first {
                for i in 0..<documents.count {
                    results.append(VectorResult(
                        content: documents[i],
                        distance: distances[i],
                        metadata: nil
                    ))
                }
            }
            
            return results
        } catch {
            throw error
        }
    }
    
    // Simple embedding generation (using simple hash for MVP)
    private func generateEmbedding(text: String) async throws -> [Double] {
        // Use simple deterministic embedding based on text
        // This works without needing LM Studio or external services
        return generateSimpleEmbedding(text: text)
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

// Simplified metadata handling - Chroma returns nested arrays
struct ChromaSearchResponse: Decodable {
    let ids: [[String]]?
    let documents: [[String]]?
    let distances: [[Double]]?
    // We'll skip metadatas decoding for MVP to avoid complexity
    // let metadatas: [[String: String]]?
}

struct EmbeddingResponse: Content {
    let data: [EmbeddingData]
}

struct EmbeddingData: Content {
    let embedding: [Double]
}
