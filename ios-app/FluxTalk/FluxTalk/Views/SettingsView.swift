import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: ChatViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var serverURL = APIService.shared.baseURL
    @State private var showClearConfirmation = false
    
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
        }
    }
}
