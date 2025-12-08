import Foundation
import Combine

@MainActor
class ChatViewModel: ObservableObject {
    @Published var messages: [Message] = []
    @Published var isLoading = false
    @Published var error: String?
    @Published var currentMode: AIMode = .local
    
    private let apiService = APIService.shared
    
    init() {
        Task {
            await loadHistory()
            await loadSettings()
        }
    }
    
    func loadHistory() async {
        do {
            messages = try await apiService.getChatHistory()
        } catch {
            self.error = "Failed to load history: \(error.localizedDescription)"
        }
    }
    
    func loadSettings() async {
        do {
            let setting = try await apiService.getSetting(key: "ai_mode")
            if let mode = AIMode(rawValue: setting.value) {
                currentMode = mode
            }
        } catch {
            // Use default mode if not found
            currentMode = .local
        }
    }
    
    func sendMessage(_ text: String) async {
        guard !text.isEmpty else { return }
        
        isLoading = true
        error = nil
        
        do {
            let response = try await apiService.sendMessage(text)
            
            // Reload history to get the latest messages
            await loadHistory()
            
        } catch {
            self.error = "Failed to send message: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func clearHistory() async {
        do {
            try await apiService.clearChatHistory()
            messages = []
        } catch {
            self.error = "Failed to clear history: \(error.localizedDescription)"
        }
    }
    
    func changeMode(_ mode: AIMode) async {
        do {
            _ = try await apiService.setSetting(key: "ai_mode", value: mode.rawValue)
            currentMode = mode
        } catch {
            self.error = "Failed to change mode: \(error.localizedDescription)"
        }
    }
}
