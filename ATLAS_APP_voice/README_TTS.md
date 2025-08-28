# Azure Text-to-Speech Setup Guide

This guide will help you set up and use Azure Text-to-Speech services with the provided Python code.

## 🔑 Required Azure Keys

From your Azure Speech Service in the Azure Portal, you need to copy these **2 key pieces of information**:

### 1. Subscription Key (API Key)
- Go to your Azure Speech Service resource in the Azure Portal
- Navigate to **"Keys and Endpoint"** in the left sidebar
- Copy either **KEY 1** or **KEY 2** (both work the same)
- This is your `AZURE_SPEECH_KEY`

### 2. Region
- In the same **"Keys and Endpoint"** section
- Look for **"Location/Region"** (e.g., `eastus`, `westus2`, `westeurope`)
- This is your `AZURE_SPEECH_REGION`

## 🚀 Quick Setup

### Step 1: Install Dependencies
```bash
pip install -r requirements.txt
```

### Step 2: Set Environment Variables

**Option A: Environment Variables (Recommended)**
```bash
# Windows (PowerShell)
$env:AZURE_SPEECH_KEY="your_subscription_key_here"
$env:AZURE_SPEECH_REGION="your_region_here"

# Windows (Command Prompt)
set AZURE_SPEECH_KEY=your_subscription_key_here
set AZURE_SPEECH_REGION=your_region_here

# Linux/Mac
export AZURE_SPEECH_KEY="your_subscription_key_here"
export AZURE_SPEECH_REGION="your_region_here"
```

**Option B: Create config.py file**
```bash
# Copy the example config
cp config_example.py config.py
# Edit config.py with your actual keys
```

### Step 3: Test the Setup
```bash
python example_usage.py
```

## 📁 Files Overview

- `azure_tts.py` - Main TTS class with all functionality
- `example_usage.py` - Examples and interactive demo  
- `requirements.txt` - Python dependencies
- `config_example.py` - Configuration template
- `README_TTS.md` - This setup guide

## 🎯 Basic Usage

```python
from azure_tts import AzureTextToSpeech

# Initialize with your keys
tts = AzureTextToSpeech(
    subscription_key="your_key_here",
    region="your_region_here"
)

# Speak text
tts.speak_text("Hello, this is Azure Text-to-Speech!")

# Save to audio file
tts.text_to_audio_file("Hello world!", "output.wav")

# Change voice
tts.set_voice("en-US-DavisNeural")  # Male voice
tts.speak_text("Now I'm using a different voice!")
```

## 🎭 Popular Voice Options

| Voice Name | Language | Gender | Description |
|------------|----------|---------|-------------|
| `en-US-AriaNeural` | English (US) | Female | Clear, professional |
| `en-US-DavisNeural` | English (US) | Male | Warm, friendly |
| `en-GB-SoniaNeural` | English (UK) | Female | British accent |
| `fr-FR-DeniseNeural` | French | Female | Native French |
| `es-ES-ElviraNeural` | Spanish | Female | Native Spanish |
| `ar-SA-ZariyahNeural` | Arabic | Female | Native Arabic |

## 🔧 Advanced Features

### SSML (Speech Synthesis Markup Language)
```python
ssml = """
<speak version="1.0" xmlns="http://www.w3.org/2001/10/synthesis" xml:lang="en-US">
    <voice name="en-US-AriaNeural">
        Hello! <break time="500ms"/> 
        I can speak <emphasis level="strong">loudly</emphasis> 
        or <prosody rate="slow">slowly</prosody>.
    </voice>
</speak>
"""
tts.speak_ssml(ssml)
```

### List Available Voices
```python
voices = tts.get_available_voices()
for voice in voices:
    print(f"{voice['name']} - {voice['locale']}")
```

## ❗ Troubleshooting

### Common Issues:

1. **"Invalid subscription key"**
   - Double-check your `AZURE_SPEECH_KEY`
   - Make sure you copied the key correctly (no extra spaces)

2. **"Invalid region"** 
   - Verify your `AZURE_SPEECH_REGION` matches your Azure resource
   - Use the short region name (e.g., `eastus`, not `East US`)

3. **"No audio output"**
   - Check your system audio settings
   - Try saving to file first: `tts.text_to_audio_file("test", "test.wav")`

4. **Import errors**
   - Make sure you installed requirements: `pip install -r requirements.txt`
   - You might need to upgrade pip: `pip install --upgrade pip`

### Testing Your Setup:
```bash
# Test 1: Check environment variables
python -c "import os; print('Key:', os.getenv('AZURE_SPEECH_KEY')[:10] + '...' if os.getenv('AZURE_SPEECH_KEY') else 'Not set'); print('Region:', os.getenv('AZURE_SPEECH_REGION'))"

# Test 2: Quick speech test
python -c "from azure_tts import create_tts_from_env; tts = create_tts_from_env(); tts.speak_text('Test') if tts else print('Setup failed')"
```

## 💡 Tips

- **Free Tier**: Azure provides 500,000 characters per month free
- **Audio Formats**: Default is WAV, but you can configure other formats
- **Rate Limiting**: Azure has rate limits, so add delays for batch processing
- **Voice Quality**: Neural voices (like AriaNeural) sound more natural than standard voices
- **Languages**: Azure supports 100+ languages and dialects

## 📞 Need Help?

If you encounter issues:
1. Check the Azure Portal to ensure your Speech Service is active
2. Verify your subscription hasn't exceeded limits
3. Test with the interactive demo: `python example_usage.py` → choice `6`

Happy speech synthesizing! 🎤


