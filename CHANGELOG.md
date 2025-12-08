# Changelog

All notable changes to the Flux Talk project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2024-12-08

### Added - MVP Release

#### Backend (Vapor/Swift)
- ✅ Vapor web framework server running on port 8080
- ✅ SQLite database for persistent chat message storage
- ✅ Message and Setting database models with Fluent ORM
- ✅ Database migrations for automatic schema setup
- ✅ AI provider abstraction layer supporting multiple backends
- ✅ LM Studio integration (local, OpenAI-compatible API)
- ✅ Grok API integration (xAI)
- ✅ OpenAI API integration (GPT-4)
- ✅ Vector database service with Chroma integration
- ✅ Fallback simple embedding generation for offline use
- ✅ RESTful API endpoints:
  - `/health` - Server health check
  - `/api/chat` - Send messages and get AI responses
  - `/api/chat/history` - Retrieve chat history
  - `/api/settings` - Manage AI mode and other settings
  - `/api/vector/add` - Add content to vector database
  - `/api/vector/search` - Search vector database for context
- ✅ CORS middleware for cross-origin requests
- ✅ Context-enhanced chat using vector database retrieval

#### iOS Frontend (SwiftUI)
- ✅ Native iOS app with SwiftUI
- ✅ Swift Package structure for easy integration
- ✅ Chat view with message bubbles
- ✅ User and assistant message differentiation
- ✅ Settings view with:
  - Server URL configuration
  - AI mode switching (Local/Grok/OpenAI)
  - Chat history clearing
- ✅ API service layer for backend communication
- ✅ ChatViewModel with MVVM architecture
- ✅ Real-time message updates
- ✅ Error handling and display
- ✅ Loading states for async operations
- ✅ Timestamp display for messages

#### Web Frontend (React.js + Vite)
- ✅ Modern React 19 application
- ✅ Vite dev server with hot module replacement
- ✅ Responsive chat interface
- ✅ Message bubbles with role-based styling
- ✅ Settings modal with:
  - AI mode selection
  - Knowledge base management
  - Vector database search interface
  - Chat history clearing
- ✅ API service layer matching backend endpoints
- ✅ Real-time chat updates
- ✅ Error handling and user feedback
- ✅ Auto-scroll to latest messages
- ✅ Timestamp formatting
- ✅ Loading indicators

#### Documentation
- ✅ Comprehensive README.md with:
  - Architecture diagram
  - Tech stack details
  - Quick start guide
  - Setup instructions for all components
  - Configuration guide
  - API endpoint overview
  - Troubleshooting section
- ✅ API.md with complete API documentation
- ✅ QUICKSTART.md for rapid setup
- ✅ CONTRIBUTING.md for developers
- ✅ API testing script (test-api.sh)
- ✅ Automated setup script (setup.sh)
- ✅ Environment configuration examples
- ✅ MIT License

#### Configuration & DevOps
- ✅ .gitignore files for all components
- ✅ Docker Compose configuration for Chroma
- ✅ Environment variable templates
- ✅ Package management (Swift PM, npm)

### Architecture
- Local-first design with optional cloud AI providers
- Modular architecture allowing easy component updates
- Clear separation between frontend, backend, and AI providers
- Database abstraction for future database migrations
- API versioning ready structure

### Technical Details
- **Backend:** Vapor 4.99+, Fluent ORM, Swift 5.9+, SQLite
- **iOS:** SwiftUI, iOS 17+, Swift Package Manager
- **Web:** React 19, Vite 7, Modern ES6+
- **AI:** OpenAI-compatible API support, Chroma vector database
- **Platform:** Cross-platform (macOS, Linux for backend; iOS for mobile; Web for desktop)

### Known Limitations
- No user authentication (MVP)
- Single user/conversation model
- No media support (text only)
- No push notifications
- Basic error handling
- No request rate limiting
- Simple embedding fallback (not production-grade)
- Chroma integration optional (falls back gracefully)
- Backend uses Swift 5.9 for Vapor compatibility (iOS uses Swift 6.0)

### Future Enhancements (Roadmap)
- [ ] User authentication and authorization
- [ ] Multiple conversation threads
- [ ] Media support (images, voice, files)
- [ ] Advanced vector database querying
- [ ] Export/import chat history
- [ ] Custom model parameters configuration
- [ ] iOS push notifications
- [ ] Dark mode for all interfaces
- [ ] Multi-language support
- [ ] Message editing and deletion
- [ ] Search within conversations
- [ ] Analytics and usage statistics
- [ ] Advanced AI provider settings
- [ ] Streaming responses
- [ ] Conversation branching
- [ ] Collaborative features

[1.0.0]: https://github.com/transparenceco/flux_talk/releases/tag/v1.0.0
