import SwiftUI

struct ChatView: View {
    @StateObject private var viewModel = ChatViewModel()
    @State private var messageText = ""
    @State private var showSettings = false
    
    var body: some View {
        NavigationView {
            VStack {
                // Messages list
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.messages) { message in
                                MessageBubble(message: message)
                                    .id(message.id)
                            }
                        }
                        .padding()
                    }
                    .onChange(of: viewModel.messages.count) { _, _ in
                        if let lastMessage = viewModel.messages.last {
                            withAnimation {
                                proxy.scrollTo(lastMessage.id, anchor: .bottom)
                            }
                        }
                    }
                }
                
                // Error message
                if let error = viewModel.error {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)
                        .padding(.horizontal)
                }
                
                // Input area
                HStack {
                    TextField("Type a message...", text: $messageText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .disabled(viewModel.isLoading)
                    
                    Button(action: {
                        Task {
                            await viewModel.sendMessage(messageText)
                            messageText = ""
                        }
                    }) {
                        if viewModel.isLoading {
                            ProgressView()
                        } else {
                            Image(systemName: "paperplane.fill")
                        }
                    }
                    .disabled(messageText.isEmpty || viewModel.isLoading)
                }
                .padding()
            }
            .navigationTitle("Flux Talk")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Text(viewModel.currentMode.displayName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showSettings = true
                    }) {
                        Image(systemName: "gear")
                    }
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView(viewModel: viewModel)
            }
        }
    }
}

struct MessageBubble: View {
    let message: Message
    
    var body: some View {
        HStack {
            if message.isUser {
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    Text(message.content)
                        .padding(12)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(16)
                    
                    if let createdAt = message.createdAt {
                        Text(createdAt, style: .time)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            } else {
                VStack(alignment: .leading, spacing: 4) {
                    Text(message.content)
                        .padding(12)
                        .background(Color(.systemGray6))
                        .foregroundColor(.primary)
                        .cornerRadius(16)
                    
                    HStack {
                        if let createdAt = message.createdAt {
                            Text(createdAt, style: .time)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        Text("· \(message.provider)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                Spacer()
            }
        }
    }
}

#Preview {
    ChatView()
}
