# Flux Talk - Quick Start Launchers

Choose the appropriate launcher for your operating system:

## macOS
**Double-click:** `launch.command`

The terminal window will open and automatically start all services. Your web browser will open to the application.

## Windows
**Double-click:** `launch.bat`

Several terminal windows will open (one for each service). Your default browser will open to the application.

## Linux
**Terminal:** Run `bash launch-linux.sh`

Or **File Manager:** Right-click `launch-linux.sh` → Open With → Terminal

## What Gets Started

The launcher automatically starts three services:

1. **Chroma Vector Database** (Port 8000)
   - Stores and retrieves knowledge/context

2. **Backend Server** (Port 8080)
   - Swift/Vapor API server
   - Handles chat logic and AI integration

3. **Web App** (Port 3001)
   - React/Vite frontend
   - User interface

## Accessing the App

Once all services are running, open your browser to:

```
http://localhost:3001
```

## Stopping the Services

### macOS/Linux
- Press `Ctrl+C` in the terminal window, or
- Close the terminal window

### Windows
- Close each terminal window that was opened

## Troubleshooting

If services don't start:

1. **Check logs:**
   - Chroma: `/tmp/chroma.log`
   - Backend: `/tmp/backend.log`
   - Frontend: `/tmp/frontend.log`

2. **Port conflicts:** Make sure ports 8000, 8080, 3001 are available

3. **Dependencies:**
   - Ensure Python 3 is installed
   - Ensure Swift 5.9+ is installed (for macOS/Linux)
   - Ensure Node.js 18+ is installed

4. **Rerun the launcher** to automatically clean up and retry
