import SwiftUI

struct ContentView: View {
    @State private var message: String = ""
    @State private var conversationId: Int? = nil
    @State private var log: [String] = []

    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                Text("Flux Talk iOS")
                    .font(.largeTitle)
                    .bold()
                Text("Minimal SwiftUI client mirroring the web chat and settings.")
                    .font(.subheadline)
                ScrollView {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(log, id: \.__self) { line in
                            Text(line)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(8)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(8)
                        }
                    }
                }
                HStack {
                    TextField("Message", text: $message)
                        .textFieldStyle(.roundedBorder)
                    Button("Send", action: sendMessage)
                        .buttonStyle(.borderedProminent)
                }
            }
            .padding()
        }
    }

    func sendMessage() {
        guard let url = URL(string: "http://localhost:8000/chat") else { return }
        let payload: [String: Any] = [
            "conversation_id": conversationId as Any,
            "message": ["content": message, "role": "user"],
            "model_source": [
                "name": "LM Studio",
                "is_local": true,
                "host": "http://localhost:1234"
            ]
        ]

        guard let data = try? JSONSerialization.data(withJSONObject: payload) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = data

        URLSession.shared.dataTask(with: request) { data, _, _ in
            guard let data else { return }
            if let result = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let conversation = result["conversation"] as? [String: Any],
               let reply = result["reply"] as? [String: Any] {
                conversationId = conversation["id"] as? Int
                let userLine = "You: \(message)"
                let replyLine = "Assistant: \(reply["content"] as? String ?? "")"
                DispatchQueue.main.async {
                    log.append(contentsOf: [userLine, replyLine])
                    message = ""
                }
            }
        }.resume()
    }
}

#Preview {
    ContentView()
}
