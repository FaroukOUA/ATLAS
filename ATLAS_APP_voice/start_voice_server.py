#!/usr/bin/env python3
"""
Startup script for Azure Voice Services API Server
Run this before using the Flutter voice chat feature
"""

import os
import sys
import subprocess
from pathlib import Path

def check_environment():
    """Check if required environment variables are set"""
    required_vars = ['AZURE_SPEECH_KEY', 'AZURE_SPEECH_REGION']
    missing_vars = []
    
    for var in required_vars:
        if not os.getenv(var):
            missing_vars.append(var)
    
    if missing_vars:
        print("❌ Missing required environment variables:")
        for var in missing_vars:
            print(f"   - {var}")
        print("\nPlease set these environment variables before running the server.")
        print("\nExample (Windows PowerShell):")
        print('$env:AZURE_SPEECH_KEY="your_key_here"')
        print('$env:AZURE_SPEECH_REGION="your_region_here"')
        print("\nExample (Linux/Mac):")
        print('export AZURE_SPEECH_KEY="your_key_here"')
        print('export AZURE_SPEECH_REGION="your_region_here"')
        return False
    
    return True

def check_dependencies():
    """Check if required Python packages are installed"""
    try:
        import azure.cognitiveservices.speech
        import flask
        import flask_cors
        print("✅ All required packages are installed")
        return True
    except ImportError as e:
        print(f"❌ Missing required package: {e}")
        print("\nPlease install dependencies:")
        print("pip install -r requirements.txt")
        return False

def main():
    """Main startup function"""
    print("🎙️ Azure Voice Services - Startup Script")
    print("=" * 50)
    
    # Check current directory
    current_dir = Path.cwd()
    print(f"📁 Current directory: {current_dir}")
    
    # Check if we're in the right directory
    flask_api_path = None
    
    # Option 1: Check current directory (if running from ATLAS_APP_voice)
    if (current_dir / "flask_voice_api.py").exists():
        flask_api_path = current_dir / "flask_voice_api.py"
        print("✅ Found flask_voice_api.py in current directory")
    # Option 2: Check ATLAS_APP_voice subdirectory (if running from ATLAS)
    elif (current_dir / "ATLAS_APP_voice" / "flask_voice_api.py").exists():
        flask_api_path = current_dir / "ATLAS_APP_voice" / "flask_voice_api.py"
        # Change to ATLAS_APP_voice directory
        os.chdir(current_dir / "ATLAS_APP_voice")
        print(f"✅ Found flask_voice_api.py, changed to: {current_dir / 'ATLAS_APP_voice'}")
    else:
        print("❌ flask_voice_api.py not found!")
        print("Please run this script from either:")
        print("  - ATLAS/ATLAS_APP_voice/ directory, or")
        print("  - ATLAS/ directory")
        return 1
    
    # Check environment variables
    print("\n🔧 Checking environment variables...")
    if not check_environment():
        return 1
    
    print("✅ Environment variables are set")
    
    # Check dependencies
    print("\n📦 Checking dependencies...")
    if not check_dependencies():
        return 1
    
    # Start the Flask server
    print("\n🚀 Starting Flask API server...")
    print("📱 Flutter app will be able to connect to voice services")
    print("⏹️  Press Ctrl+C to stop the server")
    print("\n" + "=" * 50)
    
    try:
        # Run the Flask app
        subprocess.run([sys.executable, "flask_voice_api.py"])
    except KeyboardInterrupt:
        print("\n\n⏹️  Server stopped by user")
        print("👋 Goodbye!")
    except Exception as e:
        print(f"\n❌ Error running server: {e}")
        return 1
    
    return 0

if __name__ == "__main__":
    exit_code = main()
    sys.exit(exit_code)

