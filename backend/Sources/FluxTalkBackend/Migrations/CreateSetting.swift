import Fluent

struct CreateSetting: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("settings")
            .id()
            .field("key", .string, .required)
            .field("value", .string, .required)
            .field("updated_at", .datetime)
            .unique(on: "key")
            .create()
    }
    
    func revert(on database: Database) async throws {
        try await database.schema("settings").delete()
    }
}
