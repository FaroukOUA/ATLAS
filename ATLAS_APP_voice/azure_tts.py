import azure.cognitiveservices.speech as speechsdk
import os
from typing import Optional
import logging

class AzureTextToSpeech:
    """
    Azure Text-to-Speech wrapper class for easy TTS functionality.
    
    Requires Azure Speech Service subscription key and region.
    """
    
    def __init__(self, subscription_key: str, region: str):
        """
        Initialize Azure TTS client.
        
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
        
        # Set default voice (you can change this)
        self.speech_config.speech_synthesis_voice_name = "ar-MA-JamalNeural"
        
        # Configure logging
        logging.basicConfig(level=logging.INFO)
        self.logger = logging.getLogger(__name__)
    
    def set_voice(self, voice_name: str):
        """
        Set the voice for speech synthesis.
        
        Popular voices:
        - en-US-AriaNeural (female, US English)
        - en-US-DavisNeural (male, US English)
        - en-GB-SoniaNeural (female, British English)
        - fr-FR-DeniseNeural (female, French)
        - es-ES-ElviraNeural (female, Spanish)
        
        Args:
            voice_name (str): Azure voice name
        """
        self.speech_config.speech_synthesis_voice_name = voice_name
        self.logger.info(f"Voice set to: {voice_name}")
    
    def speak_text(self, text: str) -> bool:
        """
        Convert text to speech and play it through speakers.
        
        Args:
            text (str): Text to convert to speech
            
        Returns:
            bool: True if successful, False otherwise
        """
        try:
            # Create synthesizer with default speaker
            synthesizer = speechsdk.SpeechSynthesizer(speech_config=self.speech_config)
            
            # Perform synthesis
            result = synthesizer.speak_text_async(text).get()
            
            if result.reason == speechsdk.ResultReason.SynthesizingAudioCompleted:
                self.logger.info(f"Speech synthesis completed for text: '{text[:50]}...'")
                return True
            elif result.reason == speechsdk.ResultReason.Canceled:
                cancellation_details = result.cancellation_details
                self.logger.error(f"Speech synthesis canceled: {cancellation_details.reason}")
                if cancellation_details.error_details:
                    self.logger.error(f"Error details: {cancellation_details.error_details}")
                return False
                
        except Exception as e:
            self.logger.error(f"Error in speech synthesis: {str(e)}")
            return False
    
    def text_to_audio_file(self, text: str, output_file: str) -> bool:
        """
        Convert text to speech and save as audio file.
        
        Args:
            text (str): Text to convert to speech
            output_file (str): Output audio file path (.wav format)
            
        Returns:
            bool: True if successful, False otherwise
        """
        try:
            # Create audio configuration for file output
            audio_config = speechsdk.audio.AudioOutputConfig(filename=output_file)
            
            # Create synthesizer with file output
            synthesizer = speechsdk.SpeechSynthesizer(
                speech_config=self.speech_config, 
                audio_config=audio_config
            )
            
            # Perform synthesis
            result = synthesizer.speak_text_async(text).get()
            
            if result.reason == speechsdk.ResultReason.SynthesizingAudioCompleted:
                self.logger.info(f"Audio saved to: {output_file}")
                return True
            elif result.reason == speechsdk.ResultReason.Canceled:
                cancellation_details = result.cancellation_details
                self.logger.error(f"Speech synthesis canceled: {cancellation_details.reason}")
                if cancellation_details.error_details:
                    self.logger.error(f"Error details: {cancellation_details.error_details}")
                return False
                
        except Exception as e:
            self.logger.error(f"Error saving audio file: {str(e)}")
            return False
    
    def speak_ssml(self, ssml: str) -> bool:
        """
        Convert SSML (Speech Synthesis Markup Language) to speech.
        
        Args:
            ssml (str): SSML markup text
            
        Returns:
            bool: True if successful, False otherwise
        """
        try:
            synthesizer = speechsdk.SpeechSynthesizer(speech_config=self.speech_config)
            result = synthesizer.speak_ssml_async(ssml).get()
            
            if result.reason == speechsdk.ResultReason.SynthesizingAudioCompleted:
                self.logger.info("SSML speech synthesis completed")
                return True
            elif result.reason == speechsdk.ResultReason.Canceled:
                cancellation_details = result.cancellation_details
                self.logger.error(f"SSML synthesis canceled: {cancellation_details.reason}")
                return False
                
        except Exception as e:
            self.logger.error(f"Error in SSML synthesis: {str(e)}")
            return False
    
    def get_available_voices(self) -> Optional[list]:
        """
        Get list of available voices for the current region.
        
        Returns:
            list: List of available voices or None if error
        """
        try:
            synthesizer = speechsdk.SpeechSynthesizer(speech_config=self.speech_config)
            result = synthesizer.get_voices_async().get()
            
            if result.reason == speechsdk.ResultReason.VoicesListRetrieved:
                voices = []
                for voice in result.voices:
                    voices.append({
                        'name': voice.name,
                        'display_name': voice.display_name,
                        'locale': voice.locale,
                        'gender': voice.gender.name
                    })
                return voices
            else:
                self.logger.error("Failed to retrieve voices list")
                return None
                
        except Exception as e:
            self.logger.error(f"Error getting voices: {str(e)}")
            return None


def create_tts_from_env() -> Optional[AzureTextToSpeech]:
    """
    Create AzureTextToSpeech instance from environment variables.
    
    Expected environment variables:
    - AZURE_SPEECH_KEY: Your Azure Speech Service subscription key
    - AZURE_SPEECH_REGION: Your Azure region
    
    Returns:
        AzureTextToSpeech: Configured TTS instance or None if env vars missing
    """
    subscription_key = os.getenv('AZURE_SPEECH_KEY')
    region = os.getenv('AZURE_SPEECH_REGION')
    
    if not subscription_key or not region:
        print("Error: Missing environment variables!")
        print("Please set:")
        print("- AZURE_SPEECH_KEY: Your Azure Speech Service subscription key")
        print("- AZURE_SPEECH_REGION: Your Azure region (e.g., 'eastus')")
        return None
    
    return AzureTextToSpeech(subscription_key, region)


if __name__ == "__main__":
    # Example usage
    print("Azure Text-to-Speech Example")
    print("=" * 40)
    
    # Try to create TTS from environment variables
    tts = create_tts_from_env()
    
    if tts:
        # Test basic speech
        test_text = "Hello! This is Azure Text-to-Speech in action. How are you today?"
        print(f"Speaking: {test_text}")
        
        success = tts.speak_text(test_text)
        if success:
            print("✅ Speech synthesis successful!")
        else:
            print("❌ Speech synthesis failed!")
            
        # Save to file
        output_file = "test_output.wav"
        print(f"\nSaving speech to: {output_file}")
        
        if tts.text_to_audio_file(test_text, output_file):
            print("✅ Audio file saved successfully!")
        else:
            print("❌ Failed to save audio file!")
    else:
        print("❌ Failed to initialize Azure TTS. Check your environment variables.")


