import Vapor

class VectorDBService {
    private let app: Application
    private let chromaURL: String
    private let collectionName = "flux_talk_context"
    private var cachedCollectionId: String?
    
    init(app: Application) {
        self.app = app
        self.chromaURL = Environment.get("CHROMA_URL") ?? "http://127.0.0.1:8000"
    }
    
    // Create or fetch the collection and return its id
    private func ensureCollection() async throws -> String {
        if let cachedCollectionId {
            return cachedCollectionId
        }
        
        // Try to find existing collection by name
        if let existingId = try await fetchCollectionId() {
            cachedCollectionId = existingId
            return existingId
        }
        
        // Otherwise create it
        struct CollectionRequest: Content {
            let name: String
            let metadata: [String: String]?
        }
        
        let collectionReq = CollectionRequest(
            name: collectionName,
            metadata: ["description": "Flux Talk context storage"]
        )
        
        let createResponse = try await app.client.post(
            URI(string: "\(chromaURL)/api/v1/collections")
        ) { req in
            try req.content.encode(collectionReq)
        }
        
        if let collection = try? createResponse.content.decode(ChromaCollectionResponse.self).collection {
            cachedCollectionId = collection.id
            return collection.id
        }
        
        // If creation failed (maybe already exists), try one more fetch
        if let fallbackId = try await fetchCollectionId() {
            cachedCollectionId = fallbackId
            return fallbackId
        }
        
        throw Abort(.internalServerError, reason: "Unable to initialize Chroma collection")
    }
    
    private func fetchCollectionId() async throws -> String? {
        let encodedName = collectionName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? collectionName
        let uri = URI(string: "\(chromaURL)/api/v1/collections?name=\(encodedName)")
        let response = try await app.client.get(uri)
        
        // Primary response shape: { "collection": { ... } }
        if let collection = try? response.content.decode(ChromaCollectionResponse.self).collection {
            return collection.id
        }
        
        // Alternative response shape: { "collections": [ { ... } ] }
        if let collections = try? response.content.decode(ChromaCollectionsResponse.self).collections {
            return collections.first(where: { $0.name == collectionName })?.id
        }
        
        return nil
    }
    
    // Add content to vector DB
    func addContent(id: String, content: String, metadata: [String: String]?) async throws {
        let embedding = try await generateEmbedding(text: content)
        let collectionId = try await ensureCollection()
        
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
                URI(string: "\(chromaURL)/api/v1/collections/\(collectionId)/add")
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
        let collectionId = try await ensureCollection()
        
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
                URI(string: "\(chromaURL)/api/v1/collections/\(collectionId)/query")
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

struct ChromaCollectionResponse: Decodable {
    let collection: ChromaCollection
}

struct ChromaCollectionsResponse: Decodable {
    let collections: [ChromaCollection]?
}

struct ChromaCollection: Decodable {
    let id: String
    let name: String?
    let metadata: [String: String]?
}

struct EmbeddingResponse: Content {
    let data: [EmbeddingData]
}

struct EmbeddingData: Content {
    let embedding: [Double]
}
