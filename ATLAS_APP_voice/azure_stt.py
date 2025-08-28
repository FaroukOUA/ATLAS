import azure.cognitiveservices.speech as speechsdk
import os
from typing import Optional, Callable
import logging
import threading
import time

class AzureSpeechToText:
    """
    Azure Speech-to-Text wrapper class for Arabic voice recognition.
    
    Requires Azure Speech Service subscription key and region.
    """
    
    def __init__(self, subscription_key: str, region: str):
        """
        Initialize Azure STT client.
        
        Args:
            subscription_key (str): Azure Speech Service subscription key
            region (str): Azure region (e.g., 'eastus', 'westus2')
        """
        self.subscription_key = subscription_key
        self.region = region
        
        # Create speech configuration
        self.speech_config = speechsdk.SpeechConfig(
            subscription=subscription_key, 
            region=region
        )
        
        # Set language to Arabic (Morocco/Darija)
        self.speech_config.speech_recognition_language = "ar-MA"
        
        # Configure audio input
        self.audio_config = speechsdk.audio.AudioConfig(use_default_microphone=True)
        
        # Configure logging
        logging.basicConfig(level=logging.INFO)
        self.logger = logging.getLogger(__name__)
        
        # Recognition state
        self.is_listening = False
        self.recognition_result = None
        
    def set_language(self, language_code: str):
        """
        Set the recognition language.
        
        Popular Arabic language codes:
        - ar-MA: Arabic (Morocco) - Darija
        - ar-SA: Arabic (Saudi Arabia) - Standard Arabic
        - ar-EG: Arabic (Egypt)
        - ar-AE: Arabic (UAE)
        
        Args:
            language_code (str): Language code for recognition
        """
        self.speech_config.speech_recognition_language = language_code
        self.logger.info(f"Language set to: {language_code}")
    
    def recognize_once(self) -> Optional[str]:
        """
        Recognize speech from microphone (single utterance).
        
        Returns:
            str: Recognized text or None if recognition failed
        """
        try:
            # Create recognizer
            recognizer = speechsdk.SpeechRecognizer(
                speech_config=self.speech_config, 
                audio_config=self.audio_config
            )
            
            self.logger.info("Listening for speech... Speak now!")
            
            # Perform recognition
            result = recognizer.recognize_once()
            
            if result.reason == speechsdk.ResultReason.RecognizedSpeech:
                self.logger.info(f"Recognized: {result.text}")
                return result.text
            elif result.reason == speechsdk.ResultReason.NoMatch:
                self.logger.warning("No speech could be recognized")
                return None
            elif result.reason == speechsdk.ResultReason.Canceled:
                cancellation_details = result.cancellation_details
                self.logger.error(f"Speech recognition canceled: {cancellation_details.reason}")
                if cancellation_details.error_details:
                    self.logger.error(f"Error details: {cancellation_details.error_details}")
                return None
                
        except Exception as e:
            self.logger.error(f"Error in speech recognition: {str(e)}")
            return None
    
    def recognize_from_file(self, audio_file_path: str) -> Optional[str]:
        """
        Recognize speech from audio file.
        
        Args:
            audio_file_path (str): Path to audio file (.wav format)
            
        Returns:
            str: Recognized text or None if recognition failed
        """
        try:
            # Create audio configuration from file
            audio_config = speechsdk.audio.AudioConfig(filename=audio_file_path)
            
            # Create recognizer
            recognizer = speechsdk.SpeechRecognizer(
                speech_config=self.speech_config, 
                audio_config=audio_config
            )
            
            self.logger.info(f"Recognizing speech from file: {audio_file_path}")
            
            # Perform recognition
            result = recognizer.recognize_once()
            
            if result.reason == speechsdk.ResultReason.RecognizedSpeech:
                self.logger.info(f"Recognized from file: {result.text}")
                return result.text
            elif result.reason == speechsdk.ResultReason.NoMatch:
                self.logger.warning("No speech could be recognized from file")
                return None
            elif result.reason == speechsdk.ResultReason.Canceled:
                cancellation_details = result.cancellation_details
                self.logger.error(f"Speech recognition canceled: {cancellation_details.reason}")
                return None
                
        except Exception as e:
            self.logger.error(f"Error recognizing from file: {str(e)}")
            return None
    
    def start_continuous_recognition(self, 
                                   on_recognized: Callable[[str], None],
                                   on_recognizing: Optional[Callable[[str], None]] = None) -> bool:
        """
        Start continuous speech recognition.
        
        Args:
            on_recognized (Callable): Callback for final recognized text
            on_recognizing (Callable, optional): Callback for intermediate results
            
        Returns:
            bool: True if started successfully, False otherwise
        """
        try:
            if self.is_listening:
                self.logger.warning("Already listening!")
                return False
            
            # Create recognizer
            self.recognizer = speechsdk.SpeechRecognizer(
                speech_config=self.speech_config, 
                audio_config=self.audio_config
            )
            
            # Set up event handlers
            def recognized_handler(evt):
                if evt.result.reason == speechsdk.ResultReason.RecognizedSpeech:
                    self.logger.info(f"Final result: {evt.result.text}")
                    on_recognized(evt.result.text)
            
            def recognizing_handler(evt):
                if on_recognizing and evt.result.text:
                    self.logger.debug(f"Intermediate result: {evt.result.text}")
                    on_recognizing(evt.result.text)
            
            def canceled_handler(evt):
                self.logger.error(f"Recognition canceled: {evt.reason}")
                self.is_listening = False
            
            # Connect event handlers
            self.recognizer.recognized.connect(recognized_handler)
            if on_recognizing:
                self.recognizer.recognizing.connect(recognizing_handler)
            self.recognizer.canceled.connect(canceled_handler)
            
            # Start continuous recognition
            self.recognizer.start_continuous_recognition()
            self.is_listening = True
            self.logger.info("Started continuous recognition. Speak continuously...")
            
            return True
            
        except Exception as e:
            self.logger.error(f"Error starting continuous recognition: {str(e)}")
            return False
    
    def stop_continuous_recognition(self):
        """Stop continuous speech recognition."""
        try:
            if hasattr(self, 'recognizer') and self.is_listening:
                self.recognizer.stop_continuous_recognition()
                self.is_listening = False
                self.logger.info("Stopped continuous recognition")
            else:
                self.logger.warning("Not currently listening")
                
        except Exception as e:
            self.logger.error(f"Error stopping recognition: {str(e)}")
    
    def test_microphone(self) -> bool:
        """
        Test if microphone is working.
        
        Returns:
            bool: True if microphone test successful, False otherwise
        """
        try:
            # Create a simple recognizer for testing
            recognizer = speechsdk.SpeechRecognizer(
                speech_config=self.speech_config,
                audio_config=self.audio_config
            )
            
            self.logger.info("Testing microphone... Say something in Arabic!")
            
            # Short recognition test (5 seconds timeout)
            result = recognizer.recognize_once()
            
            if result.reason == speechsdk.ResultReason.RecognizedSpeech:
                self.logger.info(f"Microphone test successful! Heard: {result.text}")
                return True
            elif result.reason == speechsdk.ResultReason.NoMatch:
                self.logger.warning("Microphone working but no clear speech detected")
                return True  # Microphone is working, just no clear speech
            else:
                self.logger.error("Microphone test failed")
                return False
                
        except Exception as e:
            self.logger.error(f"Microphone test error: {str(e)}")
            return False


def create_stt_from_env() -> Optional[AzureSpeechToText]:
    """
    Create AzureSpeechToText instance from environment variables.
    
    Expected environment variables:
    - AZURE_SPEECH_KEY: Your Azure Speech Service subscription key
    - AZURE_SPEECH_REGION: Your Azure region
    
    Returns:
        AzureSpeechToText: Configured STT instance or None if env vars missing
    """
    subscription_key = os.getenv('AZURE_SPEECH_KEY')
    region = os.getenv('AZURE_SPEECH_REGION')
    
    if not subscription_key or not region:
        print("Error: Missing environment variables!")
        print("Please set:")
        print("- AZURE_SPEECH_KEY: Your Azure Speech Service subscription key")
        print("- AZURE_SPEECH_REGION: Your Azure region (e.g., 'eastus')")
        return None
    
    return AzureSpeechToText(subscription_key, region)


if __name__ == "__main__":
    # Example usage
    print("Azure Speech-to-Text Example")
    print("=" * 40)
    
    # Try to create STT from environment variables
    stt = create_stt_from_env()
    
    if stt:
        # Test microphone first
        print("Testing microphone...")
        if stt.test_microphone():
            print("✅ Microphone test successful!")
        else:
            print("❌ Microphone test failed!")
            exit(1)
        
        # Test single recognition
        print("\n🎤 Single Recognition Test")
        print("Speak something in Arabic...")
        
        recognized_text = stt.recognize_once()
        if recognized_text:
            print(f"✅ Recognized: {recognized_text}")
        else:
            print("❌ No speech recognized!")
        
        # Test continuous recognition
        print("\n🔄 Continuous Recognition Test")
        print("Starting continuous recognition... Speak continuously!")
        print("Press Ctrl+C to stop")
        
        def on_final_result(text):
            print(f"🗣️  Final: {text}")
        
        def on_intermediate_result(text):
            print(f"📝 Partial: {text}", end='\r')
        
        try:
            if stt.start_continuous_recognition(on_final_result, on_intermediate_result):
                # Keep listening until interrupted
                while stt.is_listening:
                    time.sleep(0.1)
            else:
                print("❌ Failed to start continuous recognition!")
                
        except KeyboardInterrupt:
            print("\n\n⏹️  Stopping recognition...")
            stt.stop_continuous_recognition()
            print("👋 Goodbye!")
            
    else:
        print("❌ Failed to initialize Azure STT. Check your environment variables.")

