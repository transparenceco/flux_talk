@echo off
REM Flux Talk - Application Launcher for Windows
REM Double-click this file to start the application

setlocal enabledelayedexpansion

cd /d "%~dp0"

echo.
echo ========================================
echo    Flux Talk - Launching Services
echo ========================================
echo.

REM Kill any existing services
echo Cleaning up existing processes...
taskkill /F /IM "swift" /T 2>nul || true
taskkill /F /IM "node" /T 2>nul || true
taskkill /F /IM "chroma" /T 2>nul || true
timeout /t 2 /nobreak >nul

REM Check for Python virtual environment
if not exist ".venv" (
    echo Creating Python virtual environment...
    python -m venv .venv
    call .venv\Scripts\activate.bat
    pip install chromadb >nul 2>&1
) else (
    call .venv\Scripts\activate.bat
)

REM Start Chroma Vector Database
echo Starting Chroma Vector Database (port 8000)...
start "Chroma - Flux Talk" cmd /k ".venv\Scripts\chroma run --host localhost --port 8000"
timeout /t 3 /nobreak >nul

REM Start Backend (Vapor)
echo Starting Backend Server (port 8080)...
cd backend
start "Backend - Flux Talk" cmd /k "swift run"
timeout /t 8 /nobreak >nul
cd ..

REM Start Frontend (React/Vite)
echo Starting Web App (port 3001)...
cd web-app
start "Frontend - Flux Talk" cmd /k "npm run dev"
timeout /t 3 /nobreak >nul
cd ..

echo.
echo ========================================
echo    Services Started Successfully
echo ========================================
echo.
echo Services Running:
echo   Web App:     http://localhost:3001
echo   Backend:     http://localhost:8080
echo   Chroma DB:   http://localhost:8000
echo.
echo Opening web app in browser...
timeout /t 1 /nobreak >nul

REM Open the web app in default browser
start http://localhost:3001

echo.
echo Flux Talk is ready to use!
echo.
echo To stop all services, close the terminal windows that were opened.
echo.

pause
