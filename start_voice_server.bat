@echo off
echo 🎙️ Starting Azure Voice Services Server
echo ========================================

cd /d "%~dp0"
echo 📁 Current directory: %CD%

echo 🚀 Starting voice server...
python "ATLAS_APP_voice\start_voice_server.py"

echo.
echo ⏹️ Server stopped
pause
