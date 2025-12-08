#!/bin/bash

echo "🚀 Flux Talk MVP Setup Script"
echo "================================"
echo ""

# Check prerequisites
echo "Checking prerequisites..."

# Check Swift
if ! command -v swift &> /dev/null; then
    echo "❌ Swift is not installed. Please install Swift 6.0+ from https://swift.org"
    exit 1
fi
echo "✅ Swift $(swift --version | head -n 1)"

# Check Node.js
if ! command -v node &> /dev/null; then
    echo "❌ Node.js is not installed. Please install Node.js 18+ from https://nodejs.org"
    exit 1
fi
echo "✅ Node.js $(node --version)"

# Check npm
if ! command -v npm &> /dev/null; then
    echo "❌ npm is not installed"
    exit 1
fi
echo "✅ npm $(npm --version)"

echo ""
echo "📦 Installing dependencies..."
echo ""

# Setup backend
echo "Setting up backend..."
cd backend || exit 1
if [ ! -f .env ]; then
    cp .env.example .env
    echo "Created backend/.env file - please edit it to add your API keys"
fi
swift package resolve
echo "✅ Backend dependencies resolved"
cd ..

# Setup web app
echo ""
echo "Setting up web app..."
cd web-app || exit 1
if [ ! -f .env ]; then
    cp .env.example .env
    echo "Created web-app/.env file"
fi
npm install
echo "✅ Web app dependencies installed"
cd ..

echo ""
echo "✅ Setup complete!"
echo ""
echo "📋 Next steps:"
echo ""
echo "1. Install and start LM Studio:"
echo "   - Download from https://lmstudio.ai/"
echo "   - Download a model (e.g., Mistral 7B)"
echo "   - Start the local server (default port 1234)"
echo ""
echo "2. (Optional) Start Chroma vector database:"
echo "   pip install chromadb"
echo "   chroma run --host localhost --port 8000"
echo ""
echo "3. Start the backend server:"
echo "   cd backend && swift run"
echo ""
echo "4. In a new terminal, start the web app:"
echo "   cd web-app && npm run dev"
echo ""
echo "5. Open http://localhost:3000 in your browser"
echo ""
echo "For iOS app setup, see README.md"
echo ""
