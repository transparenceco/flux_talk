# Flux Talk - Quick Reference

## 🚀 Quick Start (3 Commands)

```bash
./setup.sh              # Setup everything
cd backend && swift run # Start backend
cd web-app && npm run dev # Start web (new terminal)
```

Then open: http://localhost:3000

## 📋 Essential Commands

### Backend
```bash
cd backend
swift build         # Build
swift run          # Run server (port 8080)
```

### Web App
```bash
cd web-app
npm install        # Install dependencies
npm run dev        # Development (port 3000)
npm run build      # Production build
```

### iOS App
```bash
cd ios-app/FluxTalk
open Package.swift # Open in Xcode
# Then: Run in Xcode
```

## 🔧 Configuration

### Backend (.env)
```bash
cd backend
cp .env.example .env
# Edit .env to add:
# GROK_API_KEY=your_key
# OPENAI_API_KEY=your_key
```

### Web (.env)
```bash
cd web-app
cp .env.example .env
# Edit VITE_API_URL if needed
# Default: http://localhost:8080
```

## 🤖 AI Modes

| Mode | Requires | Privacy |
|------|----------|---------|
| **Local** | LM Studio on :1234 | ✅ 100% Private |
| **Grok** | GROK_API_KEY env var | ❌ Cloud |
| **OpenAI** | OPENAI_API_KEY env var | ❌ Cloud |

## 📡 API Endpoints

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/health` | GET | Health check |
| `/api/chat` | POST | Send message |
| `/api/chat/history` | GET | Get messages |
| `/api/chat/history` | DELETE | Clear messages |
| `/api/settings` | GET/POST | Manage settings |
| `/api/vector/add` | POST | Add knowledge |
| `/api/vector/search` | POST | Search knowledge |

## 📱 Ports

- Backend: **8080**
- Web App: **3000**
- LM Studio: **1234** (default)
- Chroma: **8000** (optional)

## 🧪 Testing

```bash
# Start backend first
cd backend && swift run &

# Run API tests
./test-api.sh
```

## 🐛 Troubleshooting

### Port 8080 in use
```bash
lsof -ti:8080 | xargs kill -9
```

### Can't connect to backend
1. Check backend is running
2. Check CORS settings
3. Verify URL in web/.env

### iOS app can't connect
1. Update Server URL in settings
2. Use your computer's IP (not localhost)
3. Ensure same WiFi network

## 📂 Key Files

```
flux_talk/
├── README.md              # Full documentation
├── API.md                 # API reference
├── QUICKSTART.md          # Quick start
├── CONTRIBUTING.md        # Dev guide
├── PROJECT_SUMMARY.md     # Project overview
├── setup.sh              # Auto setup
├── test-api.sh           # API tests
├── backend/              # Vapor server
├── ios-app/              # iOS app
└── web-app/              # React app
```

## 🎯 Common Tasks

### Switch AI Mode (Web)
1. Click ⚙️ Settings
2. Select mode (Local/Grok/OpenAI)
3. Click "Save Mode"

### Add Knowledge (Web)
1. Click ⚙️ Settings
2. Go to "Knowledge Base"
3. Enter text
4. Click "Add Knowledge"

### Clear History
- **Web:** Settings → Clear All Messages
- **iOS:** Settings → Clear Chat History
- **API:** `curl -X DELETE localhost:8080/api/chat/history`

## 📚 Documentation

- **Full Docs:** [README.md](README.md)
- **API Docs:** [API.md](API.md)
- **Quick Start:** [QUICKSTART.md](QUICKSTART.md)
- **Dev Guide:** [CONTRIBUTING.md](CONTRIBUTING.md)
- **Summary:** [PROJECT_SUMMARY.md](PROJECT_SUMMARY.md)

## 🆘 Help

- Check logs in terminal
- Read error messages
- See CONTRIBUTING.md for debugging
- Review API.md for endpoint details

## ✅ Checklist

Before starting:
- [ ] LM Studio installed (for local mode)
- [ ] Swift installed
- [ ] Node.js installed

After setup:
- [ ] Backend builds successfully
- [ ] Web app runs on :3000
- [ ] Can send/receive messages
- [ ] Settings work correctly

---

**Version:** 1.0.0 | **License:** MIT | **Status:** Ready 🚀
