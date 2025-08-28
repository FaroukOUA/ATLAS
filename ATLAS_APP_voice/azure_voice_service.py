import os
import json
import logging
from typing import Optional, Dict, Any
from azure_tts import AzureTextToSpeech, create_tts_from_env
from azure_stt import AzureSpeechToText, create_stt_from_env

class AzureVoiceService:
    """
    Combined Azure Voice Service for Text-to-Speech and Speech-to-Text.
    Designed for Arabic voice interactions with the first aid chatbot.
    """
    
    def __init__(self, subscription_key: str, region: str):
        """
        Initialize combined voice service.
        
        Args:
            subscription_key (str): Azure Speech Service subscription key
            region (str): Azure region (e.g., 'eastus', 'westus2')
        """
        self.subscription_key = subscription_key
        self.region = region
        
        # Initialize TTS and STT services
        self.tts = AzureTextToSpeech(subscription_key, region)
        self.stt = AzureSpeechToText(subscription_key, region)
        
        # Set Arabic voice for TTS (Morocco)
        self.tts.set_voice("ar-MA-JamalNeural")  # Male Arabic voice
        
        # Set Arabic language for STT (Morocco/Darija)
        self.stt.set_language("ar-MA")
        
        # Configure logging
        logging.basicConfig(level=logging.INFO)
        self.logger = logging.getLogger(__name__)
        
        self.logger.info("Azure Voice Service initialized for Arabic")
    
    def speak_and_listen(self, text_to_speak: str, listen_timeout: int = 10) -> Optional[str]:
        """
        Speak text and then listen for user response.
        
        Args:
            text_to_speak (str): Arabic text to speak
            listen_timeout (int): Seconds to wait for user speech
            
        Returns:
            str: User's speech as text, or None if no speech detected
        """
        try:
            # Speak the text
            self.logger.info(f"Speaking: {text_to_speak[:50]}...")
            if not self.tts.speak_text(text_to_speak):
                self.logger.error("Failed to speak text")
                return None
            
            # Small pause before listening
            import time
            time.sleep(0.5)
            
            # Listen for response
            self.logger.info("Listening for your response...")
            user_speech = self.stt.recognize_once()
            
            if user_speech:
                self.logger.info(f"User said: {user_speech}")
                return user_speech
            else:
                self.logger.warning("No speech detected")
                return None
                
        except Exception as e:
            self.logger.error(f"Error in speak_and_listen: {str(e)}")
            return None
    
    def voice_conversation(self, chatbot_response: str) -> Optional[str]:
        """
        Handle a complete voice interaction cycle.
        
        Args:
            chatbot_response (str): Response from chatbot to speak
            
        Returns:
            str: User's next question/input, or None if conversation ends
        """
        # Speak the chatbot response
        if not self.tts.speak_text(chatbot_response):
            self.logger.error("Failed to speak chatbot response")
            return None
        
        # Wait a moment, then listen for user's next question
        import time
        time.sleep(1)
        
        self.logger.info("🎤 Listening for your next question...")
        user_input = self.stt.recognize_once()
        
        if user_input:
            self.logger.info(f"User asked: {user_input}")
            return user_input
        else:
            self.logger.info("No follow-up question detected")
            return None
    
    def save_conversation_audio(self, text: str, filename: str) -> bool:
        """
        Save chatbot response as audio file.
        
        Args:
            text (str): Text to convert to speech
            filename (str): Output filename (e.g., "response.wav")
            
        Returns:
            bool: True if successful, False otherwise
        """
        return self.tts.text_to_audio_file(text, filename)
    
    def test_voice_setup(self) -> Dict[str, bool]:
        """
        Test both TTS and STT functionality.
        
        Returns:
            dict: Test results for TTS and STT
        """
        results = {
            "tts_working": False,
            "stt_working": False,
            "microphone_working": False
        }
        
        # Test TTS
        try:
            test_text = "مرحبا! هذا اختبار لخدمة التحويل من النص إلى الكلام."
            results["tts_working"] = self.tts.speak_text(test_text)
            self.logger.info(f"TTS Test: {'✅ Passed' if results['tts_working'] else '❌ Failed'}")
        except Exception as e:
            self.logger.error(f"TTS Test failed: {e}")
        
        # Test microphone
        try:
            results["microphone_working"] = self.stt.test_microphone()
            self.logger.info(f"Microphone Test: {'✅ Passed' if results['microphone_working'] else '❌ Failed'}")
        except Exception as e:
            self.logger.error(f"Microphone Test failed: {e}")
        
        # Test STT
        if results["microphone_working"]:
            try:
                self.logger.info("Testing STT... Please say something in Arabic!")
                test_recognition = self.stt.recognize_once()
                results["stt_working"] = test_recognition is not None
                self.logger.info(f"STT Test: {'✅ Passed' if results['stt_working'] else '❌ Failed'}")
                if test_recognition:
                    self.logger.info(f"STT recognized: {test_recognition}")
            except Exception as e:
                self.logger.error(f"STT Test failed: {e}")
        
        return results
    
    def set_arabic_voice(self, voice_type: str = "male"):
        """
        Set Arabic voice for TTS.
        
        Args:
            voice_type (str): "male" or "female"
        """
        if voice_type.lower() == "male":
            self.tts.set_voice("ar-MA-JamalNeural")  # Male Moroccan Arabic
        elif voice_type.lower() == "female":
            self.tts.set_voice("ar-MA-MounaNeural")  # Female Moroccan Arabic
        else:
            self.logger.warning(f"Unknown voice type: {voice_type}. Using default male voice.")
            self.tts.set_voice("ar-MA-JamalNeural")
    
    def create_voice_interaction_data(self, user_speech: str, bot_response: str) -> Dict[str, Any]:
        """
        Create structured data for voice interactions.
        
        Args:
            user_speech (str): What user said
            bot_response (str): Chatbot's response
            
        Returns:
            dict: Structured interaction data
        """
        import datetime
        
        return {
            "timestamp": datetime.datetime.now().isoformat(),
            "user_speech": user_speech,
            "bot_response": bot_response,
            "language": "ar-MA",
            "interaction_type": "voice"
        }


def create_voice_service_from_env() -> Optional[AzureVoiceService]:
    """
    Create AzureVoiceService instance from environment variables.
    
    Returns:
        AzureVoiceService: Configured voice service or None if env vars missing
    """
    subscription_key = os.getenv('AZURE_SPEECH_KEY')
    region = os.getenv('AZURE_SPEECH_REGION')
    
    if not subscription_key or not region:
        print("Error: Missing environment variables!")
        print("Please set:")
        print("- AZURE_SPEECH_KEY: Your Azure Speech Service subscription key")
        print("- AZURE_SPEECH_REGION: Your Azure region (e.g., 'eastus')")
        return None
    
    return AzureVoiceService(subscription_key, region)


if __name__ == "__main__":
    # Example voice interaction
    print("🎙️ Azure Voice Service Demo")
    print("=" * 50)
    
    voice_service = create_voice_service_from_env()
    
    if voice_service:
        # Test the setup
        print("Testing voice setup...")
        test_results = voice_service.test_voice_setup()
        
        if all(test_results.values()):
            print("✅ All tests passed! Voice service is ready.")
            
            # Demo conversation
            print("\n🗣️ Voice Conversation Demo")
            print("The chatbot will speak, then listen for your response...")
            
            # Simulate chatbot response
            chatbot_response = "مرحبا! أنا مساعد الإسعافات الأولية. كيف يمكنني مساعدتك اليوم؟"
            
            user_input = voice_service.voice_conversation(chatbot_response)
            
            if user_input:
                print(f"✅ Conversation successful!")
                print(f"User said: {user_input}")
                
                # Create interaction data
                interaction = voice_service.create_voice_interaction_data(
                    user_input, chatbot_response
                )
                print(f"Interaction logged: {interaction}")
            else:
                print("❌ No user response detected")
        else:
            print("❌ Some tests failed:")
            for test, result in test_results.items():
                status = "✅" if result else "❌"
                print(f"  {status} {test}")
    else:
        print("❌ Failed to initialize voice service")

