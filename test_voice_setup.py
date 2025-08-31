#!/usr/bin/env python3
"""
Test script for Voice Chat functionality
Run this to diagnose and fix voice-related issues
"""

import os
import sys
import requests
import json
from pathlib import Path

def test_environment_variables():
    """Test if Azure environment variables are set"""
    print("🔧 Testing Environment Variables...")
    
    key = os.getenv('AZURE_SPEECH_KEY')
    region = os.getenv('AZURE_SPEECH_REGION')
    
    if not key:
        print("❌ AZURE_SPEECH_KEY not set!")
        return False
    
    if not region:
        print("❌ AZURE_SPEECH_REGION not set!")
        return False
    
    print(f"✅ AZURE_SPEECH_KEY: {key[:10]}...")
    print(f"✅ AZURE_SPEECH_REGION: {region}")
    return True

def test_flask_server(base_url="http://localhost:5000"):
    """Test if Flask server is running and responsive"""
    print(f"\n🌐 Testing Flask Server at {base_url}...")
    
    try:
        # Test health endpoint
        response = requests.get(f"{base_url}/health", timeout=5)
        if response.status_code == 200:
            data = response.json()
            print("✅ Flask server is running")
            print(f"✅ Voice service ready: {data.get('voice_service_ready', False)}")
            return True
        else:
            print(f"❌ Server responded with status: {response.status_code}")
            return False
            
    except requests.exceptions.ConnectionError:
        print("❌ Cannot connect to Flask server!")
        print("Make sure to run: python ATLAS_APP_voice/start_voice_server.py")
        return False
    except Exception as e:
        print(f"❌ Error testing server: {e}")
        return False

def test_speech_to_text(base_url="http://localhost:5000"):
    """Test Speech-to-Text endpoint"""
    print(f"\n🎤 Testing Speech-to-Text endpoint...")
    
    try:
        response = requests.post(
            f"{base_url}/speech-to-text",
            json={"language": "ar-MA"},
            timeout=10
        )
        
        if response.status_code == 200:
            data = response.json()
            if data.get('success'):
                print("✅ STT endpoint is working")
                if data.get('text'):
                    print(f"✅ Recognized text: {data['text']}")
                else:
                    print("⚠️ STT endpoint works but no speech detected (expected)")
            else:
                print(f"⚠️ STT endpoint responded but no speech: {data.get('error', 'Unknown')}")
        else:
            print(f"❌ STT endpoint failed with status: {response.status_code}")
            return False
            
    except Exception as e:
        print(f"❌ Error testing STT: {e}")
        return False
    
    return True

def test_text_to_speech(base_url="http://localhost:5000"):
    """Test Text-to-Speech file endpoint"""
    print(f"\n🔊 Testing Text-to-Speech endpoint...")
    
    test_text = "مرحبا! هذا اختبار للتحويل من النص إلى الكلام باللغة العربية."
    
    try:
        response = requests.post(
            f"{base_url}/text-to-speech-file",
            json={
                "text": test_text,
                "voice": "ar-MA-MounaNeural"
            },
            timeout=15
        )
        
        if response.status_code == 200:
            # Check if we got audio data
            if len(response.content) > 1000:  # Audio files are typically larger
                print("✅ TTS endpoint is working")
                print(f"✅ Generated audio file size: {len(response.content)} bytes")
                
                # Save test audio file
                test_file = Path("test_tts_output.wav")
                with open(test_file, "wb") as f:
                    f.write(response.content)
                print(f"✅ Test audio saved to: {test_file}")
                return True
            else:
                print("❌ TTS endpoint returned data but seems too small for audio")
                return False
        else:
            print(f"❌ TTS endpoint failed with status: {response.status_code}")
            try:
                error_data = response.json()
                print(f"Error details: {error_data}")
            except:
                print(f"Response content: {response.text[:200]}")
            return False
            
    except Exception as e:
        print(f"❌ Error testing TTS: {e}")
        return False

def test_flutter_dependencies():
    """Check if Flutter dependencies are properly configured"""
    print(f"\n📦 Testing Flutter Dependencies...")
    
    pubspec_path = Path("pubspec.yaml")
    if not pubspec_path.exists():
        print("❌ pubspec.yaml not found! Run from ATLAS directory.")
        return False
    
    with open(pubspec_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    required_deps = [
        'audioplayers',
        'path_provider',
        'http',
        'flutter_markdown'
    ]
    
    missing_deps = []
    for dep in required_deps:
        if dep not in content:
            missing_deps.append(dep)
    
    if missing_deps:
        print(f"❌ Missing dependencies: {missing_deps}")
        return False
    else:
        print("✅ All required Flutter dependencies are present")
        return True

def test_android_permissions():
    """Check if Android permissions are configured"""
    print(f"\n📱 Testing Android Permissions...")
    
    manifest_path = Path("android/app/src/main/AndroidManifest.xml")
    if not manifest_path.exists():
        print("❌ AndroidManifest.xml not found!")
        return False
    
    with open(manifest_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    required_permissions = [
        'RECORD_AUDIO',
        'INTERNET'
    ]
    
    missing_permissions = []
    for perm in required_permissions:
        if perm not in content:
            missing_permissions.append(perm)
    
    if missing_permissions:
        print(f"❌ Missing Android permissions: {missing_permissions}")
        return False
    else:
        print("✅ All required Android permissions are present")
        return True

def main():
    """Run all tests"""
    print("🎙️ Voice Chat Functionality Test")
    print("=" * 50)
    
    # Change to ATLAS directory if needed
    if Path("ATLAS").exists():
        os.chdir("ATLAS")
        print("📁 Changed to ATLAS directory")
    
    tests = [
        ("Environment Variables", test_environment_variables),
        ("Flutter Dependencies", test_flutter_dependencies),
        ("Android Permissions", test_android_permissions),
        ("Flask Server", test_flask_server),
        ("Speech-to-Text", test_speech_to_text),
        ("Text-to-Speech", test_text_to_speech),
    ]
    
    results = {}
    for test_name, test_func in tests:
        try:
            results[test_name] = test_func()
        except Exception as e:
            print(f"❌ {test_name} test failed with error: {e}")
            results[test_name] = False
    
    # Summary
    print(f"\n📊 Test Results Summary")
    print("=" * 30)
    
    passed = 0
    for test_name, result in results.items():
        status = "✅ PASS" if result else "❌ FAIL"
        print(f"{status} {test_name}")
        if result:
            passed += 1
    
    print(f"\nPassed: {passed}/{len(tests)} tests")
    
    if passed == len(tests):
        print("\n🎉 All tests passed! Voice chat should work properly.")
    else:
        print("\n⚠️ Some tests failed. Please fix the issues above.")
        print("\n🔧 Quick fixes:")
        if not results.get("Environment Variables", True):
            print("- Set Azure environment variables")
        if not results.get("Flask Server", True):
            print("- Start the voice server: python ATLAS_APP_voice/start_voice_server.py")
        if not results.get("Flutter Dependencies", True):
            print("- Run: flutter pub get")
        if not results.get("Android Permissions", True):
            print("- Add missing permissions to AndroidManifest.xml")

if __name__ == "__main__":
    main()

