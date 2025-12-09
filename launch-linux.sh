#!/bin/bash

# Flux Talk - Application Launcher for Linux
# This script starts all necessary services for the Flux Talk application

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║      Flux Talk - Launching Services    ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
echo ""

# Function to check if a service is already running
check_port() {
    nc -z localhost "$1" >/dev/null 2>&1
    return $?
}

# Kill any existing services
echo -e "${YELLOW}Cleaning up existing processes...${NC}"
pkill -f 'swift run' 2>/dev/null || true
pkill -f 'chroma run' 2>/dev/null || true
pkill -f 'npm run dev' 2>/dev/null || true
sleep 2

# Check for Python virtual environment
if [ ! -d ".venv" ]; then
    echo -e "${YELLOW}Python virtual environment not found. Creating...${NC}"
    python3 -m venv .venv
    source .venv/bin/activate
    pip install chromadb > /dev/null 2>&1
else
    source .venv/bin/activate
fi

# Start Chroma Vector Database
echo -e "${YELLOW}Starting Chroma Vector Database (port 8000)...${NC}"
.venv/bin/chroma run --host localhost --port 8000 > /tmp/chroma.log 2>&1 &
CHROMA_PID=$!
sleep 3

if check_port 8000; then
    echo -e "${GREEN}✓ Chroma started (PID: $CHROMA_PID)${NC}"
else
    echo -e "${YELLOW}⚠ Chroma may be starting, waiting a bit longer...${NC}"
    sleep 3
fi

# Start Backend (Vapor)
echo -e "${YELLOW}Starting Backend Server (port 8080)...${NC}"
cd "$SCRIPT_DIR/backend"
nohup swift run > /tmp/backend.log 2>&1 &
BACKEND_PID=$!
sleep 8

if check_port 8080; then
    echo -e "${GREEN}✓ Backend started (PID: $BACKEND_PID)${NC}"
else
    echo -e "${YELLOW}⚠ Backend may be starting, waiting a bit longer...${NC}"
    sleep 5
fi

# Start Frontend (React/Vite)
echo -e "${YELLOW}Starting Web App (port 3001)...${NC}"
cd "$SCRIPT_DIR/web-app"
nohup npm run dev > /tmp/frontend.log 2>&1 &
FRONTEND_PID=$!
sleep 3

if check_port 3001; then
    echo -e "${GREEN}✓ Frontend started (PID: $FRONTEND_PID)${NC}"
else
    echo -e "${YELLOW}⚠ Frontend may be starting, checking logs...${NC}"
    tail -5 /tmp/frontend.log
    sleep 3
fi

echo ""
echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║        Services Started Successfully   ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
echo ""
echo -e "${GREEN}Services Running:${NC}"
echo -e "  🌐 Web App:     ${GREEN}http://localhost:3001${NC}"
echo -e "  🔌 Backend:     ${GREEN}http://localhost:8080${NC}"
echo -e "  📊 Chroma DB:   ${GREEN}http://localhost:8000${NC}"
echo ""
echo -e "${YELLOW}Opening web app in browser...${NC}"
sleep 1

# Open the web app in default browser
if command -v xdg-open &> /dev/null; then
    xdg-open http://localhost:3001 &
elif command -v firefox &> /dev/null; then
    firefox http://localhost:3001 &
elif command -v google-chrome &> /dev/null; then
    google-chrome http://localhost:3001 &
else
    echo -e "${YELLOW}Please open http://localhost:3001 in your browser${NC}"
fi

echo ""
echo -e "${GREEN}Flux Talk is ready to use!${NC}"
echo ""
echo -e "${YELLOW}Process IDs (for stopping services):${NC}"
echo "  Chroma:   $CHROMA_PID"
echo "  Backend:  $BACKEND_PID"
echo "  Frontend: $FRONTEND_PID"
echo ""
echo -e "${YELLOW}To stop all services, run: kill $CHROMA_PID $BACKEND_PID $FRONTEND_PID${NC}"
echo -e "${YELLOW}Or close this terminal window${NC}"
echo ""

# Keep the script running (so services stay alive)
wait
