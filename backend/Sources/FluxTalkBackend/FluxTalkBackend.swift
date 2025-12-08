import Vapor
import Fluent
import FluentSQLiteDriver

@main
struct FluxTalkBackend {
    static func main() async throws {
        var env = try Environment.detect()
        try LoggingSystem.bootstrap(from: &env)
        
        let app = try await Application.make(env)
        
        do {
            try await configure(app)
            try await app.execute()
            try await app.asyncShutdown()
        } catch {
            try await app.asyncShutdown()
            throw error
        }
    }
}

func configure(_ app: Application) async throws {
    // Configure SQLite database
    app.databases.use(.sqlite(.file("flux_talk.sqlite")), as: .sqlite)
    
    // Add migrations
    app.migrations.add(CreateMessage())
    app.migrations.add(CreateSetting())
    
    // Run migrations
    try await app.autoMigrate()
    
    // Initialize default settings if needed
    try await initializeDefaultSettings(app: app)
    
    // Configure CORS
    let corsConfiguration = CORSMiddleware.Configuration(
        allowedOrigin: .all,
        allowedMethods: [.GET, .POST, .PUT, .OPTIONS, .DELETE, .PATCH],
        allowedHeaders: [.accept, .authorization, .contentType, .origin, .xRequestedWith]
    )
    let cors = CORSMiddleware(configuration: corsConfiguration)
    app.middleware.use(cors)
    
    // Register routes
    try routes(app)
    
    // Configure server
    app.http.server.configuration.hostname = "0.0.0.0"
    app.http.server.configuration.port = 8080
}

func routes(_ app: Application) throws {
    // Health check
    app.get("health") { req in
        return ["status": "ok"]
    }
    
    // Register controllers
    try app.register(collection: ChatController())
    try app.register(collection: SettingsController())
    try app.register(collection: VectorController())
}

func initializeDefaultSettings(app: Application) async throws {
    let db = app.db
    
    // Check if ai_mode setting exists
    let existingMode = try await Setting.query(on: db)
        .filter(\.$key == "ai_mode")
        .first()
    
    if existingMode == nil {
        let defaultMode = Setting(key: "ai_mode", value: "local")
        try await defaultMode.save(on: db)
    }
}
