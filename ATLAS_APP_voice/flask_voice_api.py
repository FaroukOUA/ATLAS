#!/usr/bin/env python3
"""
Flask API Server for Azure Voice Services
Bridges Flutter app with Azure Speech Services (TTS + STT)
"""

from flask import Flask, request, jsonify, send_file
from flask_cors import CORS
import os
import tempfile
import uuid
from azure_voice_service import create_voice_service_from_env
import logging
import threading
import time

# Initialize Flask app
app = Flask(__name__)
CORS(app)  # Enable CORS for Flutter app

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Initialize Azure Voice Service
voice_service = None

def initialize_voice_service():
    """Initialize Azure Voice Service on startup"""
    global voice_service
    try:
        voice_service = create_voice_service_from_env()
        if voice_service:
            logger.info("✅ Azure Voice Service initialized successfully")
            return True
        else:
            logger.error("❌ Failed to initialize Azure Voice Service")
            return False
    except Exception as e:
        logger.error(f"❌ Error initializing voice service: {e}")
        return False

@app.route('/health', methods=['GET'])
def health_check():
    """Health check endpoint"""
    return jsonify({
        'status': 'healthy',
        'voice_service_ready': voice_service is not None
    })

@app.route('/test-setup', methods=['GET'])
def test_setup():
    """Test Azure voice setup"""
    if not voice_service:
        return jsonify({'error': 'Voice service not initialized'}), 500
    
    try:
        test_results = voice_service.test_voice_setup()
        return jsonify({
            'test_results': test_results,
            'all_tests_passed': all(test_results.values())
        })
    except Exception as e:
        logger.error(f"Setup test error: {e}")
        return jsonify({'error': str(e)}), 500

@app.route('/speech-to-text', methods=['POST'])
def speech_to_text():
    """Convert speech to text using Azure STT"""
    if not voice_service:
        return jsonify({'error': 'Voice service not initialized'}), 500
    
    try:
        data = request.get_json()
        language = data.get('language', 'ar-MA')
        
        # Set the language for recognition
        voice_service.stt.set_language(language)
        
        logger.info(f"Starting speech recognition in {language}...")
        
        # Perform speech recognition
        recognized_text = voice_service.stt.recognize_once()
        
        if recognized_text:
            logger.info(f"Speech recognized: {recognized_text}")
            return jsonify({
                'success': True,
                'text': recognized_text,
                'language': language
            })
        else:
            logger.warning("No speech recognized")
            return jsonify({
                'success': False,
                'text': None,
                'error': 'No speech detected'
            })
            
    except Exception as e:
        logger.error(f"STT error: {e}")
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@app.route('/text-to-speech', methods=['POST'])
def text_to_speech():
    """Convert text to speech using Azure TTS"""
    if not voice_service:
        return jsonify({'error': 'Voice service not initialized'}), 500
    
    try:
        data = request.get_json()
        text = data.get('text', '')
        voice = data.get('voice', 'ar-MA-MounaNeural')
        
        if not text:
            return jsonify({'error': 'No text provided'}), 400
        
        # Set the voice
        voice_service.tts.set_voice(voice)
        
        logger.info(f"Speaking text with voice {voice}: {text[:50]}...")
        
        # Speak the text
        success = voice_service.tts.speak_text(text)
        
        if success:
            logger.info("Text-to-speech completed successfully")
            return jsonify({
                'success': True,
                'message': 'Speech synthesis completed'
            })
        else:
            logger.error("Text-to-speech failed")
            return jsonify({
                'success': False,
                'error': 'Speech synthesis failed'
            }), 500
            
    except Exception as e:
        logger.error(f"TTS error: {e}")
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@app.route('/text-to-speech-file', methods=['POST'])
def text_to_speech_file():
    """Convert text to speech and return audio file"""
    if not voice_service:
        return jsonify({'error': 'Voice service not initialized'}), 500
    
    try:
        data = request.get_json()
        text = data.get('text', '')
        voice = data.get('voice', 'ar-MA-MounaNeural')
        
        if not text:
            return jsonify({'error': 'No text provided'}), 400
        
        # Set the voice
        voice_service.tts.set_voice(voice)
        
        # Create temporary file
        temp_file = tempfile.NamedTemporaryFile(delete=False, suffix='.wav')
        temp_filename = temp_file.name
        temp_file.close()
        
        logger.info(f"Generating audio file for text: {text[:50]}...")
        
        # Generate audio file
        success = voice_service.tts.text_to_audio_file(text, temp_filename)
        
        if success:
            logger.info(f"Audio file generated: {temp_filename}")
            
            # Return the audio file
            def remove_file(filename):
                """Remove temp file after a delay"""
                time.sleep(10)  # Wait 10 seconds before cleanup
                try:
                    os.unlink(filename)
                    logger.info(f"Cleaned up temp file: {filename}")
                except:
                    pass
            
            # Start cleanup thread
            threading.Thread(target=remove_file, args=(temp_filename,)).start()
            
            return send_file(
                temp_filename,
                mimetype='audio/wav',
                as_attachment=True,
                download_name='speech.wav'
            )
        else:
            # Clean up failed file
            try:
                os.unlink(temp_filename)
            except:
                pass
            return jsonify({
                'success': False,
                'error': 'Audio generation failed'
            }), 500
            
    except Exception as e:
        logger.error(f"TTS file error: {e}")
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@app.route('/voice-conversation', methods=['POST'])
def voice_conversation():
    """Handle complete voice conversation cycle"""
    if not voice_service:
        return jsonify({'error': 'Voice service not initialized'}), 500
    
    try:
        data = request.get_json()
        bot_response = data.get('bot_response', '')
        
        if not bot_response:
            return jsonify({'error': 'No bot response provided'}), 400
        
        logger.info(f"Starting voice conversation with response: {bot_response[:50]}...")
        
        # Speak bot response and listen for user input
        user_input = voice_service.voice_conversation(bot_response)
        
        return jsonify({
            'success': True,
            'user_input': user_input,
            'bot_response': bot_response
        })
        
    except Exception as e:
        logger.error(f"Voice conversation error: {e}")
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@app.route('/set-voice', methods=['POST'])
def set_voice():
    """Set TTS voice"""
    if not voice_service:
        return jsonify({'error': 'Voice service not initialized'}), 500
    
    try:
        data = request.get_json()
        voice_type = data.get('voice_type', 'male')
        
        voice_service.set_arabic_voice(voice_type)
        
        return jsonify({
            'success': True,
            'voice_type': voice_type,
            'message': f'Voice set to {voice_type}'
        })
        
    except Exception as e:
        logger.error(f"Set voice error: {e}")
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@app.route('/available-voices', methods=['GET'])
def available_voices():
    """Get list of available Arabic voices"""
    return jsonify({
        'voices': {
            'male': [
                {'name': 'ar-MA-JamalNeural', 'language': 'Arabic (Morocco)', 'gender': 'Male'},
                {'name': 'ar-SA-HamedNeural', 'language': 'Arabic (Saudi Arabia)', 'gender': 'Male'},
            ],
            'female': [
                {'name': 'ar-MA-MounaNeural', 'language': 'Arabic (Morocco)', 'gender': 'Female'},
                {'name': 'ar-SA-ZariyahNeural', 'language': 'Arabic (Saudi Arabia)', 'gender': 'Female'},
            ]
        }
    })

@app.errorhandler(404)
def not_found(error):
    return jsonify({'error': 'Endpoint not found'}), 404

@app.errorhandler(500)
def internal_error(error):
    return jsonify({'error': 'Internal server error'}), 500

if __name__ == '__main__':
    print("🎙️ Starting Azure Voice Services API Server")
    print("=" * 50)
    
    # Initialize voice service
    if initialize_voice_service():
        print("✅ Voice service ready!")
        print("\nAvailable endpoints:")
        print("- GET  /health - Health check")
        print("- GET  /test-setup - Test Azure setup")
        print("- POST /speech-to-text - Convert speech to text")
        print("- POST /text-to-speech - Convert text to speech")
        print("- POST /text-to-speech-file - Generate audio file")
        print("- POST /voice-conversation - Complete conversation cycle")
        print("- POST /set-voice - Set TTS voice")
        print("- GET  /available-voices - List available voices")
        print("\n🚀 Server starting on http://localhost:5000")
        print("📱 Flutter app can now connect to voice services!")
        
        # Start Flask server
        app.run(
            host='0.0.0.0',
            port=5000,
            debug=False,  # Set to True for development
            threaded=True
        )
    else:
        print("❌ Failed to initialize voice service. Check your Azure credentials.")
        print("\nMake sure you have set:")
        print("- AZURE_SPEECH_KEY environment variable")
        print("- AZURE_SPEECH_REGION environment variable")
        exit(1)

