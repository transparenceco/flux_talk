import Fluent

struct CreateMessage: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("messages")
            .id()
            .field("role", .string, .required)
            .field("content", .string, .required)
            .field("provider", .string, .required)
            .field("created_at", .datetime)
            .create()
    }
    
    func revert(on database: Database) async throws {
        try await database.schema("messages").delete()
    }
}
