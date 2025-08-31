@echo off
echo 🎙️ Voice Chat Diagnostic and Fix Script
echo ========================================

echo 📁 Current directory: %CD%

echo 🧹 Step 1: Clean Flutter project...
flutter clean

echo 📦 Step 2: Get Flutter packages...
flutter pub get

echo 🔧 Step 3: Test voice setup...
python test_voice_setup.py

echo.
echo ✅ Voice chat setup complete!
echo.
echo 📋 Next steps:
echo 1. Start voice server: start_voice_server.ps1
echo 2. Run Flutter app: flutter run
echo 3. Test voice chat in the app
echo.
pause

