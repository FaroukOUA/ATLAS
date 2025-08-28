@echo off
echo 🔄 Updating Flutter Dependencies for Voice Chat
echo =============================================

echo 📦 Getting Flutter packages...
flutter pub get

echo 🧹 Cleaning build cache...
flutter clean

echo 📦 Getting packages again...
flutter pub get

echo ✅ Dependencies updated!
echo.
echo New packages added:
echo - audioplayers: For playing audio on device
echo - path_provider: For temporary file management
echo.
echo Ready to test voice chat! 🎙️
pause
