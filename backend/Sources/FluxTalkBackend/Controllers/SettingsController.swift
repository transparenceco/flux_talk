import Vapor
import Fluent

struct SettingsController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let settings = routes.grouped("api", "settings")
        settings.get(use: getAll)
        settings.get(":key", use: get)
        settings.post(use: set)
    }
    
    func getAll(req: Request) async throws -> [SettingDTO] {
        let settings = try await Setting.query(on: req.db).all()
        return settings.map { SettingDTO(key: $0.key, value: $0.value) }
    }
    
    func get(req: Request) async throws -> SettingDTO {
        guard let key = req.parameters.get("key") else {
            throw Abort(.badRequest, reason: "Missing key parameter")
        }
        
        guard let setting = try await Setting.query(on: req.db)
            .filter(\.$key == key)
            .first() else {
            throw Abort(.notFound, reason: "Setting not found")
        }
        
        return SettingDTO(key: setting.key, value: setting.value)
    }
    
    func set(req: Request) async throws -> SettingDTO {
        let dto = try req.content.decode(SettingDTO.self)
        
        if let existing = try await Setting.query(on: req.db)
            .filter(\.$key == dto.key)
            .first() {
            existing.value = dto.value
            try await existing.update(on: req.db)
            return SettingDTO(key: existing.key, value: existing.value)
        } else {
            let newSetting = Setting(key: dto.key, value: dto.value)
            try await newSetting.save(on: req.db)
            return SettingDTO(key: newSetting.key, value: newSetting.value)
        }
    }
}
