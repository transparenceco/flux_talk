import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: ChatViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var serverURL = "http://localhost:8080"
    @State private var showClearConfirmation = false
    
    // AI Settings
    @State private var temperature: Double = 0.7
    @State private var localModel = "local-model"
    @State private var grokModel = "grok-beta"
    @State private var openaiModel = "gpt-4"
    @State private var grokApiKey = ""
    @State private var openaiApiKey = ""
    @State private var localBaseUrl = "http://localhost:1234/v1"
    @State private var useContextByDefault = true
    
    var body: some View {
        NavigationView {
            Form {
                Section("Server") {
                    TextField("Server URL", text: $serverURL)
                        .autocapitalization(.none)
                        .keyboardType(.URL)
                    
                    Button("Save Server URL") {
                        APIService.shared.baseURL = serverURL
                        Task {
                            await viewModel.loadSettings()
                            await loadAISettings()
                        }
                    }
                }
                
                Section("AI Mode") {
                    Picker("Mode", selection: Binding(
                        get: { viewModel.currentMode },
                        set: { newMode in
                            Task {
                                await viewModel.changeMode(newMode)
                            }
                        }
                    )) {
                        ForEach(AIMode.allCases, id: \.self) { mode in
                            Text(mode.displayName).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    Text("Choose between local (LM Studio), Grok, or OpenAI")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Section("AI Configuration") {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Temperature:")
                            Spacer()
                            Text(String(format: "%.2f", temperature))
                                .foregroundColor(.secondary)
                        }
                        Slider(value: $temperature, in: 0...2, step: 0.1)
                        Text("Controls randomness (0 = focused, 2 = creative)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    // Mode-specific settings
                    if viewModel.currentMode == .local {
                        TextField("LM Studio Base URL", text: $localBaseUrl)
                            .autocapitalization(.none)
                            .keyboardType(.URL)
                        
                        TextField("Model Name", text: $localModel)
                            .autocapitalization(.none)
                    }
                    
                    if viewModel.currentMode == .grok {
                        SecureField("Grok API Key", text: $grokApiKey)
                            .autocapitalization(.none)
                        
                        Picker("Model", selection: $grokModel) {
                            Text("grok-beta").tag("grok-beta")
                            Text("grok-vision-beta").tag("grok-vision-beta")
                        }
                    }
                    
                    if viewModel.currentMode == .openai {
                        SecureField("OpenAI API Key", text: $openaiApiKey)
                            .autocapitalization(.none)
                        
                        Picker("Model", selection: $openaiModel) {
                            Text("GPT-4").tag("gpt-4")
                            Text("GPT-4 Turbo").tag("gpt-4-turbo")
                            Text("GPT-3.5 Turbo").tag("gpt-3.5-turbo")
                        }
                    }
                    
                    Toggle("Use vector database context by default", isOn: $useContextByDefault)
                        .font(.callout)
                    
                    Button("Save AI Settings") {
                        Task {
                            await saveAISettings()
                        }
                    }
                }
                
                Section("Chat History") {
                    Button(role: .destructive, action: {
                        showClearConfirmation = true
                    }) {
                        Text("Clear Chat History")
                    }
                }
                
                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .alert("Clear History", isPresented: $showClearConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Clear", role: .destructive) {
                    Task {
                        await viewModel.clearHistory()
                    }
                }
            } message: {
                Text("Are you sure you want to clear all chat history? This cannot be undone.")
            }
            .task {
                // Load current server URL
                serverURL = APIService.shared.baseURL
                await loadAISettings()
            }
        }
    }
    
    private func loadAISettings() async {
        do {
            let settings = try await APIService.shared.getSettings()
            let settingsMap = Dictionary(uniqueKeysWithValues: settings.map { ($0.key, $0.value) })
            
            await MainActor.run {
                temperature = Double(settingsMap["temperature"] ?? "0.7") ?? 0.7
                localModel = settingsMap["local_model"] ?? "local-model"
                grokModel = settingsMap["grok_model"] ?? "grok-beta"
                openaiModel = settingsMap["openai_model"] ?? "gpt-4"
                grokApiKey = settingsMap["grok_api_key"] ?? ""
                openaiApiKey = settingsMap["openai_api_key"] ?? ""
                localBaseUrl = settingsMap["local_base_url"] ?? "http://localhost:1234/v1"
                useContextByDefault = settingsMap["use_context"] == "true"
            }
        } catch {
            print("Failed to load AI settings: \(error)")
        }
    }
    
    private func saveAISettings() async {
        do {
            try await APIService.shared.setSetting(key: "temperature", value: String(temperature))
            try await APIService.shared.setSetting(key: "local_model", value: localModel)
            try await APIService.shared.setSetting(key: "grok_model", value: grokModel)
            try await APIService.shared.setSetting(key: "openai_model", value: openaiModel)
            try await APIService.shared.setSetting(key: "local_base_url", value: localBaseUrl)
            try await APIService.shared.setSetting(key: "use_context", value: String(useContextByDefault))
            try await APIService.shared.setSetting(key: "grok_api_key", value: grokApiKey)
            try await APIService.shared.setSetting(key: "openai_api_key", value: openaiApiKey)
            
            // Show success alert
            print("AI settings saved successfully")
        } catch {
            print("Failed to save AI settings: \(error)")
        }
    }
}
