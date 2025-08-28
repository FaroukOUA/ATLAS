# 🎙️ Voice Services Setup Guide

## 📁 **New Directory Structure**

Your voice services are now located in:
```
ATLAS/
├── ATLAS_APP_voice/          # Voice services backend
│   ├── flask_voice_api.py    # Flask API server
│   ├── azure_tts.py          # Text-to-Speech
│   ├── azure_stt.py          # Speech-to-Text
│   ├── azure_voice_service.py # Combined service
│   ├── requirements.txt      # Python dependencies
│   └── start_voice_server.py # Startup script
├── lib/
│   └── voice_chat_page.dart  # Flutter voice UI
├── start_voice_server.bat    # Windows batch script
└── start_voice_server.ps1    # PowerShell script
```

## 🚀 **Quick Start (3 Methods)**

### **Method 1: PowerShell Script (Recommended)**
```powershell
# From ATLAS directory
.\start_voice_server.ps1
```

### **Method 2: Batch Script**
```cmd
# From ATLAS directory
start_voice_server.bat
```

### **Method 3: Direct Python**
```bash
# From ATLAS directory
python ATLAS_APP_voice\start_voice_server.py

# OR from ATLAS_APP_voice directory
cd ATLAS_APP_voice
python start_voice_server.py
```

## ⚙️ **Prerequisites**

1. **Set Azure Credentials:**
   ```powershell
   $env:AZURE_SPEECH_KEY="your_azure_key"
   $env:AZURE_SPEECH_REGION="your_region"
   ```

2. **Install Dependencies:**
   ```bash
   cd ATLAS_APP_voice
   pip install -r requirements.txt
   ```

## 🎯 **Usage Flow**

1. **Start the voice server** (using any method above)
2. **Run Flutter app:**
   ```bash
   flutter run
   ```
3. **Test voice interaction:**
   - Open app → Tap "المحادثة الصوتية"
   - Tap microphone → Speak in Arabic
   - Listen to response!

## ❗ **Troubleshooting**

### **"flask_voice_api.py not found"**
- Make sure you're running from the `ATLAS/` directory
- Or run directly from `ATLAS_APP_voice/` directory

### **"Environment variables not set"**
- Set `AZURE_SPEECH_KEY` and `AZURE_SPEECH_REGION`
- Use PowerShell script for automatic checking

### **"Connection refused" in Flutter**
- Make sure the voice server is running
- Check that it shows "Server starting on http://localhost:5000"

## 🔧 **Current Configuration**

- **Server URL**: `http://10.126.240.141:5000`
- **Voice**: `ar-MA-MounaNeural` (Female Moroccan Arabic)
- **Language**: `ar-MA` (Moroccan Arabic)

## 📱 **Flutter Integration**

The Flutter app (`voice_chat_page.dart`) is already configured to connect to your voice server. No changes needed on the Flutter side!

---

**Ready to chat with voice! 🎙️✨**
