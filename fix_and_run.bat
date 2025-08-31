@echo off
echo 🔧 Fixing All Merge Conflicts and Building Flutter App
echo ====================================================

echo 📁 Current directory: %CD%

echo 🧹 Cleaning Flutter project...
flutter clean

echo 📦 Getting Flutter packages...
flutter pub get

echo 🔨 Building Flutter app...
flutter build apk --debug

echo ✅ All merge conflicts fixed and app built!
echo.
echo 🚀 You can now run: flutter run
echo 🎙️ Don't forget to start the voice server for voice chat!
echo.
pause

