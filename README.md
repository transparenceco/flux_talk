# Flux Talk

A hybrid AI chatbot application designed for quick, private, and flexible interactions. This system provides a conversational interface with seamless switching between local (private, offline-capable) and online AI modes.

## Features

- **🔄 Mode Switching**: Toggle between local (LM Studio), Grok (xAI), and OpenAI providers
- **💾 Persistent Chat History**: All messages stored locally in SQLite
- **🧠 Context Enhancement**: Vector database (Chroma) for intelligent context retrieval
- **📱 iOS App**: Native SwiftUI mobile interface
- **🌐 Web Interface**: React-based desktop/browser access
- **🔐 Privacy First**: Local-first architecture with optional cloud AI

## Architecture

```
┌─────────────┐     ┌──────────────┐     ┌─────────────┐
│  iOS App    │────▶│              │────▶│  LM Studio  │
│  (SwiftUI)  │     │    Vapor     │     │   (Local)   │
└─────────────┘     │   Backend    │     └─────────────┘
                    │   (Swift)    │     ┌─────────────┐
┌─────────────┐     │              │────▶│    Grok     │
│   Web App   │────▶│              │     │   (Online)  │
│  (React)    │     │              │     └─────────────┘
└─────────────┘     │              │     ┌─────────────┐
                    │              │────▶│   OpenAI    │
                    └──────────────┘     │   (Online)  │
                            │            └─────────────┘
                            │
                    ┌───────┴────────┐
                    │   SQLite +     │
                    │   Chroma DB    │
                    └────────────────┘
```

## Tech Stack

- **Backend**: Vapor (server-side Swift) on port 8080
- **Databases**: 
  - SQLite for chat message persistence
  - Chroma for vector embeddings and context retrieval
- **iOS Frontend**: SwiftUI with Exyte/Chat library
- **Web Frontend**: React.js with Vite
- **AI Integration**:
  - Local: LM Studio (OpenAI-compatible API)
  - Online: Grok API (xAI) or OpenAI API

## Prerequisites

### Required
- Swift 5.9+ (for backend - uses Swift 5.9 for Vapor compatibility)
- Swift 6.0+ (for iOS app development)
- Node.js 18+ (for web frontend)
- LM Studio (for local AI mode) - https://lmstudio.ai/

### Optional
- Xcode 15+ (for iOS development)
- Chroma vector database (for context enhancement)
- Grok API key (for Grok mode)
- OpenAI API key (for OpenAI mode)

## Quick Start

### 1. Backend Setup

```bash
cd backend

# (Optional) Set API keys for online modes
cp .env.example .env
# Edit .env and add your API keys

# Build and run the backend
swift build
swift run
```

The backend server will start on `http://localhost:8080`

### 2. LM Studio Setup (for Local Mode)

1. Download and install LM Studio from https://lmstudio.ai/
2. Download a model (e.g., Mistral, Llama 2, etc.)
3. Start the local server in LM Studio:
   - Go to the "Local Server" tab
   - Click "Start Server"
   - Default port is 1234

### 3. Web App Setup

```bash
cd web-app

# Install dependencies
npm install

# (Optional) Configure API URL
cp .env.example .env
# Edit .env if backend is on a different host

# Start development server
npm run dev
```

The web app will be available at `http://localhost:3000`

### 4. iOS App Setup

```bash
cd ios-app/FluxTalk

# Build the package
swift build

# Or open in Xcode and run
open Package.swift
```

In the iOS app:
1. Go to Settings
2. Update "Server URL" to your backend IP (e.g., `http://192.168.1.100:8080`)
3. Choose your preferred AI mode

### 5. Chroma Setup (Optional - for Context Enhancement)

```bash
# Install Chroma
pip install chromadb

# Run Chroma server
chroma run --host localhost --port 8000
```

## Usage

### Web Interface

1. Open http://localhost:3000 in your browser
2. Click the Settings button (⚙️) to:
   - Switch between AI modes (Local/Grok/OpenAI)
   - Add knowledge to the vector database
   - Clear chat history
3. Type messages in the input box and press Send

### iOS App

1. Launch the app on your iOS device or simulator
2. Tap the gear icon to access settings:
   - Configure server URL
   - Switch AI modes
   - Clear history
3. Chat with the AI using the message input

### Adding Context Knowledge

**Web Interface:**
1. Click Settings
2. Go to "Knowledge Base" section
3. Enter text content
4. Click "Add Knowledge"

**API:**
```bash
curl -X POST http://localhost:8080/api/vector/add \
  -H "Content-Type: application/json" \
  -d '{"content": "Your knowledge here", "metadata": {"source": "manual"}}'
```

## API Endpoints

### Chat
- `POST /api/chat` - Send a message
  ```json
  {
    "message": "Hello!",
    "useContext": true
  }
  ```
- `GET /api/chat/history` - Get chat history
- `DELETE /api/chat/history` - Clear chat history

### Settings
- `GET /api/settings` - Get all settings
- `GET /api/settings/:key` - Get specific setting
- `POST /api/settings` - Set a setting
  ```json
  {
    "key": "ai_mode",
    "value": "local"
  }
  ```

### Vector Database
- `POST /api/vector/add` - Add content to vector DB
- `POST /api/vector/search` - Search vector DB

### Health Check
- `GET /health` - Server health status

## Configuration

### AI Mode Settings

The system supports three AI modes:

1. **Local Mode** (default)
   - Uses LM Studio running on localhost:1234
   - Completely private and offline
   - No API keys required

2. **Grok Mode**
   - Uses xAI's Grok API
   - Requires `GROK_API_KEY` environment variable
   - Set in `backend/.env`

3. **OpenAI Mode**
   - Uses OpenAI's GPT models
   - Requires `OPENAI_API_KEY` environment variable
   - Set in `backend/.env`

### Network Configuration

For cross-device access:
1. Find your computer's local IP address
2. Update the backend to listen on all interfaces (already configured: `0.0.0.0:8080`)
3. In iOS app settings, set server URL to `http://YOUR_IP:8080`
4. In web app `.env`, set `VITE_API_URL=http://YOUR_IP:8080`

## Project Structure

```
flux_talk/
├── backend/                    # Vapor backend server
│   ├── Sources/
│   │   └── FluxTalkBackend/
│   │       ├── Models/        # Database models
│   │       ├── Controllers/   # API controllers
│   │       ├── Services/      # AI and Vector DB services
│   │       ├── DTOs/          # Data transfer objects
│   │       └── Migrations/    # Database migrations
│   └── Package.swift
├── ios-app/                   # iOS application
│   └── FluxTalk/
│       └── FluxTalk/
│           ├── Models/        # Data models
│           ├── Views/         # SwiftUI views
│           ├── ViewModels/    # View models
│           └── Services/      # API service
├── web-app/                   # React web application
│   ├── src/
│   │   ├── components/       # React components
│   │   ├── services/         # API service
│   │   └── styles/           # CSS styles
│   └── package.json
└── README.md
```

## Development

### Building for Production

**Backend:**
```bash
cd backend
swift build -c release
.build/release/FluxTalkBackend
```

**Web App:**
```bash
cd web-app
npm run build
# Serve the dist/ folder with a static server
```

**iOS App:**
1. Open in Xcode
2. Select your target device/simulator
3. Product → Archive
4. Follow the distribution workflow

### Testing

The backend includes health check endpoint:
```bash
curl http://localhost:8080/health
```

Test the chat API:
```bash
curl -X POST http://localhost:8080/api/chat \
  -H "Content-Type: application/json" \
  -d '{"message": "Hello, AI!"}'
```

## Troubleshooting

### Backend won't start
- Check if port 8080 is already in use
- Verify Swift version: `swift --version`
- Check database file permissions

### LM Studio not connecting
- Ensure LM Studio server is running on port 1234
- Check if a model is loaded in LM Studio
- Verify localhost connectivity

### iOS app can't connect
- Ensure devices are on the same network
- Check server URL in app settings
- Verify backend is running and accessible
- Check firewall settings

### Web app API errors
- Verify `VITE_API_URL` in `.env`
- Check browser console for CORS errors
- Ensure backend CORS is properly configured

### Chroma not working
- Verify Chroma is running on port 8000
- Check Chroma logs for errors
- For MVP, the system will work without Chroma (falls back to simple embeddings)

## Roadmap

Future enhancements for this MVP:
- [ ] Media support (images, voice)
- [ ] Advanced vector DB querying
- [ ] User authentication
- [ ] Multiple conversation threads
- [ ] Export/import chat history
- [ ] Custom model parameters
- [ ] Push notifications (iOS)
- [ ] Dark mode
- [ ] Multi-language support

## License

MIT

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Support

For issues and questions, please open an issue on GitHub.
