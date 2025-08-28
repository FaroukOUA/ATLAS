#!/usr/bin/env python3
"""
Azure Text-to-Speech Example Usage

This script demonstrates different ways to use the Azure TTS functionality.
Make sure to set up your Azure credentials first!
"""

import os
import sys
from azure_tts import AzureTextToSpeech, create_tts_from_env

def example_basic_speech():
    """Example: Basic text-to-speech"""
    print("\n🔊 Example 1: Basic Text-to-Speech")
    print("-" * 40)
    
    # Method 1: Using environment variables (recommended)
    tts = create_tts_from_env()
    
    if not tts:
        print("❌ Could not initialize TTS. Check your environment variables.")
        return
    
    text = "أولا، ضغط على الجرح بخرقة نظيفة. خلي الصبع فوق مستوى القلب. دير ضمادة ضاغطة. إلا كان النزيف قوي سير للمستعجلات. "
    #text = "Hello! Welcome to Azure Text-to-Speech. This is a test of the speech synthesis."
    print(f"Speaking: {text}")
    
    if tts.speak_text(text):
        print("✅ Speech completed successfully!")
    else:
        print("❌ Speech failed!")

def example_different_voices():
    """Example: Using different voices"""
    print("\n🎭 Example 2: Different Voices")
    print("-" * 40)
    
    tts = create_tts_from_env()
    if not tts:
        return
    
    voices_to_test = [
        ("en-US-AriaNeural", "Hello, I'm Aria, a female voice from the US."),
        ("en-US-DavisNeural", "Hi there, I'm Davis, a male voice from the US."),
        ("en-GB-SoniaNeural", "Good day, I'm Sonia with a British accent."),
    ]
    
    for voice, text in voices_to_test:
        print(f"Testing voice: {voice}")
        tts.set_voice(voice)
        tts.speak_text(text)
        input("Press Enter to continue to next voice...")

def example_save_to_file():
    """Example: Save speech to audio file"""
    print("\n💾 Example 3: Save to Audio File")
    print("-" * 40)
    
    tts = create_tts_from_env()
    if not tts:
        return
    
    text = "This speech will be saved to an audio file for later playback."
    output_file = "saved_speech.wav"
    
    print(f"Saving speech to: {output_file}")
    
    if tts.text_to_audio_file(text, output_file):
        print(f"✅ Audio saved successfully to {output_file}")
        print(f"📁 File size: {os.path.getsize(output_file)} bytes")
    else:
        print("❌ Failed to save audio file!")

def example_ssml():
    """Example: Using SSML for advanced speech control"""
    print("\n🎯 Example 4: SSML (Advanced Speech Control)")
    print("-" * 40)
    
    tts = create_tts_from_env()
    if not tts:
        return
    
    # SSML allows you to control speech rate, pitch, emphasis, etc.
    ssml_text = """
    <speak version="1.0" xmlns="http://www.w3.org/2001/10/synthesis" xml:lang="en-US">
        <voice name="en-US-AriaNeural">
            Hello! <break time="500ms"/> 
            I can speak <emphasis level="strong">loudly</emphasis> 
            or <prosody rate="slow">slowly</prosody>.
            <break time="1s"/>
            I can even spell words: <say-as interpret-as="spell-out">SSML</say-as>
        </voice>
    </speak>
    """
    
    print("Speaking with SSML markup...")
    if tts.speak_ssml(ssml_text):
        print("✅ SSML speech completed!")
    else:
        print("❌ SSML speech failed!")

def example_list_voices():
    """Example: List available voices"""
    print("\n📋 Example 5: Available Voices")
    print("-" * 40)
    
    tts = create_tts_from_env()
    if not tts:
        return
    
    print("Fetching available voices... (this may take a moment)")
    voices = tts.get_available_voices()
    
    if voices:
        print(f"Found {len(voices)} available voices:")
        print("\nEnglish voices:")
        for voice in voices[:10]:  # Show first 10 voices
            if 'en-' in voice['locale']:
                print(f"  • {voice['name']} ({voice['locale']}) - {voice['gender']}")
        
        print(f"\n... and {len(voices) - 10} more voices available")
        print("Use tts.set_voice('voice_name') to change the voice")
    else:
        print("❌ Could not retrieve voices list")

def interactive_demo():
    """Interactive demo where user can type text to speak"""
    print("\n🎤 Interactive Demo")
    print("-" * 40)
    
    tts = create_tts_from_env()
    if not tts:
        return
    
    print("Type text to speak (or 'quit' to exit):")
    
    while True:
        user_text = input("\n> ")
        
        if user_text.lower() in ['quit', 'exit', 'q']:
            print("👋 Goodbye!")
            break
        
        if user_text.strip():
            print("🔊 Speaking...")
            if not tts.speak_text(user_text):
                print("❌ Speech failed!")
        else:
            print("Please enter some text to speak.")

def main():
    """Main function to run examples"""
    print("🎙️  Azure Text-to-Speech Examples")
    print("=" * 50)
    
    # Check if environment variables are set
    if not os.getenv('AZURE_SPEECH_KEY') or not os.getenv('AZURE_SPEECH_REGION'):
        print("⚠️  Environment variables not set!")
        print("\nTo use this script, you need to set:")
        print("1. AZURE_SPEECH_KEY - Your Azure Speech Service subscription key")
        print("2. AZURE_SPEECH_REGION - Your Azure region (e.g., 'eastus')")
        print("\nYou can set them in your system environment or create a .env file.")
        return
    
    examples = [
        ("1", "Basic Speech", example_basic_speech),
        ("2", "Different Voices", example_different_voices), 
        ("3", "Save to File", example_save_to_file),
        ("4", "SSML Advanced", example_ssml),
        ("5", "List Voices", example_list_voices),
        ("6", "Interactive Demo", interactive_demo),
        ("all", "Run All Examples", None),
    ]
    
    print("\nAvailable examples:")
    for key, name, _ in examples:
        print(f"  {key}. {name}")
    
    choice = input("\nEnter example number (or 'all'): ").strip()
    
    if choice == "all":
        for key, name, func in examples[:-2]:  # Exclude 'Interactive' and 'all'
            if func:
                func()
                input("\nPress Enter to continue to next example...")
    else:
        for key, name, func in examples:
            if key == choice and func:
                func()
                break
        else:
            print("Invalid choice!")

if __name__ == "__main__":
    main()


