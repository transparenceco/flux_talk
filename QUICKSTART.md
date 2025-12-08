# Quick Start Guide

## Option 1: Automated Setup

Run the setup script:
```bash
chmod +x setup.sh
./setup.sh
```

Then follow the on-screen instructions.

## Option 2: Manual Setup

### Step 1: Backend

```bash
cd backend
cp .env.example .env
# Edit .env to add API keys if using online modes
swift run
```

### Step 2: Web App

```bash
cd web-app
npm install
npm run dev
```

### Step 3: LM Studio (for Local Mode)

1. Download from https://lmstudio.ai/
2. Download a model
3. Start local server on port 1234

### Step 4: Access

Open http://localhost:3000 in your browser

## Testing the API

```bash
# Health check
curl http://localhost:8080/health

# Send a message
curl -X POST http://localhost:8080/api/chat \
  -H "Content-Type: application/json" \
  -d '{"message": "Hello!"}'

# Get chat history
curl http://localhost:8080/api/chat/history
```

## Switching AI Modes

In the web interface:
1. Click the Settings (⚙️) button
2. Select your preferred mode (Local/Grok/OpenAI)
3. Click "Save Mode"

## Troubleshooting

**Port 8080 already in use:**
```bash
# Find and kill the process
lsof -ti:8080 | xargs kill -9
```

**Web app can't connect to backend:**
- Check that backend is running
- Verify URL in web-app/.env
- Check browser console for errors

**LM Studio not responding:**
- Ensure server is started in LM Studio
- Check that a model is loaded
- Verify it's running on port 1234
