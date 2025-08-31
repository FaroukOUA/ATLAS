import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'services/rag_service.dart';
import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';

class VoiceChatPage extends StatefulWidget {
  final String? initialTopic;
  
  const VoiceChatPage({super.key, this.initialTopic});

  @override
  State<VoiceChatPage> createState() => _VoiceChatPageState();
}

class _VoiceChatPageState extends State<VoiceChatPage> with TickerProviderStateMixin {
  final List<Map<String, String>> _messages = [];
  bool _isListening = false;
  bool _isSpeaking = false;
  bool _isProcessing = false;
  final RAGService _ragService = RAGService();
  List<KnowledgeChunk> _lastRetrievedInfo = [];
  
  // Audio player for device playback
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  // Animation controllers
  late AnimationController _waveController;
  late AnimationController _pulseController;
  late Animation<double> _waveAnimation;
  late Animation<double> _pulseAnimation;

  // Azure service configuration
  final String azureServiceUrl = 'http://10.126.240.141:5000'; // Your computer's IP address
  
  // Initialize Google AI model
  final generationConfig = GenerationConfig();
  final systemInstruction = Content.system('''
    You are a first aid medical assistant chatbot named "مساعد الإسعافات الأولية" (First Aid Assistant), inspired by the warm and welcoming spirit of Morocco. Always respond in clear, formal Arabic (fusha), using an intuitive, friendly, and empathetic tone that reflects the hospitality and calm demeanor of an Ifrane local. Your goal is to provide accurate, step-by-step first aid guidance based on trusted medical information retrieved from an Arabic knowledge base, making users feel supported as if guided by a kind neighbor from Ifrane's serene mountain community.

    Follow these guidelines:
    1. **Tone and Personality**: Embody the warmth and tranquility of Morocco. Be approachable, reassuring, and community-oriented, like a trusted friend from a small town. Use phrases that evoke care, e.g., "أنا هنا لأساعدك بكل هدوء، كما لو كنا نتحدث في ظلال أشجار الأرز بإفران." Explain first aid steps simply, avoiding complex medical terms unless clarified (e.g., "النزيف" explained as "خروج الدم"). Show empathy, e.g., "أعلم أن هذا قد يكون مقلقًا، لكن دعنا نتعامل معه خطوة بخطوة."
    2. **Response Structure**: Provide answers in numbered lists or clear paragraphs for readability. Offer practical, actionable steps, e.g., "1. اغسل الجرح بالماء النظيف لمدة 5 دقائق." If the query is vague, ask politely for clarification, e.g., "من فضلك، هل يمكنك وصف الإصابة بمزيد من التفصيل لأساعدك بأفضل طريقة؟"
    3. **Safety and Disclaimers**: Always end responses with: "هذه المعلومات للأغراض التعليمية فقط. اطلب المساعدة الطبية المهنية فورًا أو اتصل بخدمات الطوارئ إذا كانت الحالة خطيرة."
    4. **Use Retrieved Data**: Incorporate relevant information from the Arabic knowledge base (via RAG) to ensure accuracy. If no relevant data is retrieved, use general first aid knowledge cautiously and emphasize professional help.
    5. **Cultural Sensitivity**: Reflect Ifrane's inclusive and hospitable culture. Use polite, formal Arabic (fusha) phrases (e.g., "من فضلك", "بارك الله فيك").
    6. **Edge Cases**: If the query is unrelated to first aid, respond with Ifrane-inspired warmth but redirect, e.g., "كما في إفران، نحب مشاركة المعرفة المفيدة! هل لديك سؤال عن الإسعافات الأولية، مثل التعامل مع الحروق؟"
    7. **Use Retrieved Data**: Incorporate relevant information from the Arabic knowledge base (via RAG) to ensure accuracy. If no relevant data is retrieved, use general first aid knowledge cautiously and emphasize professional help.
    8. **Response size and language**: Keep responses VERY concise (maximum 3-4 sentences or 3-4 numbered steps). Use simple, clear language. Always address the user as "مريض" (male patient) in Arabic. Avoid long explanations. THIS IS CRITICAL FOR VOICE INTERACTIONS - keep responses short and clear.Don't use stars or bold text,just plain text response.
    

    Example Response:
    للإجابة على سؤالك حول التعامل مع الحروق البسيطة:
    1. ضع المنطقة المصابة تحت ماء بارد لمدة 10 دقائق.
    2. جفف المنطقة بلطف وغطها بضمادة معقمة.
    3. لا تضع الثلج أو الزبدة على الحرق.
    هذه المعلومات للأغراض التعليمية فقط. اطلب المساعدة الطبية إذا كان الحرق كبيراً.

    Always stay within the scope of first aid, prioritize user safety, and reflect the caring spirit of Ifrane's community.
  ''');

  late final GenerativeModel model;
  late final ChatSession chat;

  @override
  void initState() {
    super.initState();
    _initializeServices();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    // Wave animation for listening state
    _waveController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _waveAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _waveController, curve: Curves.easeInOut),
    );

    // Pulse animation for speaking state
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  Future<void> _initializeServices() async {
    // Initialize RAG service first
    await _ragService.initialize();
    
    // Initialize the model and chat session
    model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: 'AIzaSyAKXgi70t9Huc9UG5rTspddYRWxC70Ne6s',
      generationConfig: generationConfig,
      systemInstruction: systemInstruction,
    );
    chat = model.startChat();
    
    // If there's an initial topic, send it automatically
    if (widget.initialTopic != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _startVoiceInteraction('أريد معلومات عن ${widget.initialTopic}');
      });
    }
  }

  Future<String?> _speechToText() async {
    try {
      print('🎤 Calling STT endpoint: $azureServiceUrl/speech-to-text');
      
      final response = await http.post(
        Uri.parse('$azureServiceUrl/speech-to-text'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'language': 'ar-MA'}),
      ).timeout(Duration(seconds: 30));
      
      print('STT Response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('STT Response data: $data');
        
        if (data['success'] == true) {
          return data['text'];
        } else {
          print('STT failed: ${data['error']}');
          _showSnackBar('فشل في التعرف على الصوت: ${data['error']}');
        }
      } else {
        print('STT HTTP error: ${response.statusCode} - ${response.body}');
        _showSnackBar('خطأ في الاتصال بخدمة التعرف على الصوت');
      }
    } catch (e) {
      print('STT Error: $e');
      _showSnackBar('خطأ في التعرف على الصوت: $e');
    }
    return null;
  }

  Future<bool> _textToSpeech(String text) async {
    try {
      print('🔊 Calling TTS endpoint: $azureServiceUrl/text-to-speech-file');
      print('TTS Text: ${text.substring(0, text.length > 50 ? 50 : text.length)}...');
      
      final response = await http.post(
        Uri.parse('$azureServiceUrl/text-to-speech-file'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'text': text,
          'voice': 'ar-MA-MounaNeural',
        }),
      ).timeout(Duration(seconds: 30));
      
      print('TTS Response status: ${response.statusCode}');
      print('TTS Response size: ${response.bodyBytes.length} bytes');
      
      if (response.statusCode == 200) {
        if (response.bodyBytes.length > 1000) {
          // Save audio file temporarily and play it
          return await _playAudioFromBytes(response.bodyBytes);
        } else {
          print('TTS response too small, likely an error');
          _showSnackBar('استجابة صوتية صغيرة جداً، ربما هناك خطأ');
          return false;
        }
      } else {
        print('TTS HTTP error: ${response.statusCode} - ${response.body}');
        _showSnackBar('خطأ في تحويل النص إلى صوت');
        return false;
      }
    } catch (e) {
      print('TTS Error: $e');
      _showSnackBar('خطأ في تشغيل الصوت: $e');
      return false;
    }
  }

  Future<bool> _playAudioFromBytes(List<int> audioBytes) async {
    try {
      print('Audio received: ${audioBytes.length} bytes');
      
      // Get temporary directory
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/temp_audio_${DateTime.now().millisecondsSinceEpoch}.wav');
      
      // Write audio bytes to temporary file
      await tempFile.writeAsBytes(audioBytes);
      print('Audio saved to: ${tempFile.path}');
      
      // Play audio on device
      await _audioPlayer.play(DeviceFileSource(tempFile.path));
      
      // Wait for audio to complete
      await _audioPlayer.onPlayerComplete.first;
      
      // Clean up temporary file
      try {
        await tempFile.delete();
      } catch (e) {
        print('Could not delete temp file: $e');
      }
      
      return true;
    } catch (e) {
      print('Audio playback error: $e');
      return false;
    }
  }

  Future<void> _startVoiceInteraction([String? initialMessage]) async {
    if (_isListening || _isSpeaking || _isProcessing) return;

    String? userMessage = initialMessage;
    
    if (userMessage == null) {
      // Start listening for user input
      setState(() {
        _isListening = true;
      });
      _waveController.repeat(reverse: true);

      userMessage = await _speechToText();
      
      _waveController.stop();
      setState(() {
        _isListening = false;
      });
    }

    if (userMessage == null || userMessage.trim().isEmpty) {
      _showSnackBar('لم يتم تسجيل أي صوت. حاول مرة أخرى.');
      return;
    }

    // Add user message to chat
    setState(() {
      _messages.add({'sender': 'user', 'text': userMessage!});
      _isProcessing = true;
    });

    try {
      // Retrieve relevant information from knowledge base
      final relevantInfo = _ragService.retrieveRelevantInfo(userMessage);
      _lastRetrievedInfo = relevantInfo;
      
      // Construct enhanced prompt with retrieved information
      String enhancedPrompt = userMessage;
      if (relevantInfo.isNotEmpty) {
        enhancedPrompt += '\n\nمعلومات مرجعية من دليل الإسعافات الأولية:\n';
        for (final chunk in relevantInfo) {
          enhancedPrompt += '\n--- ${chunk.title} ---\n${chunk.content}\n';
        }
        enhancedPrompt += '\nيرجى استخدام هذه المعلومات المرجعية لتقديم إجابة دقيقة ومفصلة باللغة العربية الدارجة المغربية.';
      }

      final response = await chat.sendMessage(Content.text(enhancedPrompt));
      final botResponse = response.text ?? 'عذرًا، لم أستطع معالجة طلبك.';
      
      setState(() {
        _messages.add({'sender': 'bot', 'text': botResponse});
        _isProcessing = false;
        _isSpeaking = true;
      });

      // Start speaking animation
      _pulseController.repeat(reverse: true);
      
      // Speak the response
      await _textToSpeech(botResponse);
      
      // Stop speaking animation
      _pulseController.stop();
      setState(() {
        _isSpeaking = false;
      });

    } catch (e) {
      setState(() {
        _messages.add({'sender': 'bot', 'text': 'حدث خطأ: $e'});
        _isProcessing = false;
        _isSpeaking = false;
      });
      _pulseController.stop();
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontFamily: 'Amiri'),
          textDirection: TextDirection.rtl,
        ),
        backgroundColor: const Color(0xFF4A7043),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'المحادثة الصوتية - مساعد الإسعافات الأولية',
          style: TextStyle(fontFamily: 'Amiri', color: Colors.white),
        ),
        backgroundColor: const Color(0xFF4A7043),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              setState(() {
                _messages.clear();
                _lastRetrievedInfo.clear();
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // RAG status indicator
          if (_lastRetrievedInfo.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              color: const Color(0xFFE6F0EA),
              child: Row(
                children: [
                  const Icon(Icons.library_books, size: 16, color: Color(0xFF4A7043)),
                  const SizedBox(width: 4),
                  Text(
                    'تم استخدام ${_lastRetrievedInfo.length} مراجع من دليل الإسعافات الأولية',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF4A7043),
                      fontFamily: 'Amiri',
                    ),
                  ),
                ],
              ),
            ),
          
          // Messages list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: _messages.length + (_isProcessing ? 1 : 0),
              itemBuilder: (context, index) {
                if (_isProcessing && index == _messages.length) {
                  return const Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4A7043)),
                      ),
                    ),
                  );
                }
                final message = _messages[index];
                final isUser = message['sender'] == 'user';
                return Align(
                  alignment: isUser ? Alignment.centerLeft : Alignment.centerRight,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.grey[200] : const Color(0xFFE6F0EA),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: isUser 
                      ? Text(
                          message['text']!,
                          style: const TextStyle(
                            fontFamily: 'Amiri',
                            fontSize: 16.0,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.left,
                          textDirection: TextDirection.ltr,
                        )
                      : Directionality(
                          textDirection: TextDirection.rtl,
                          child: MarkdownBody(
                            data: message['text']!,
                            styleSheet: MarkdownStyleSheet(
                              p: const TextStyle(
                                fontFamily: 'Amiri',
                                fontSize: 16.0,
                                color: Colors.black87,
                                height: 1.4,
                              ),
                              strong: const TextStyle(
                                fontFamily: 'Amiri',
                                fontSize: 16.0,
                                color: Colors.black87,
                                fontWeight: FontWeight.bold,
                              ),
                              listBullet: const TextStyle(
                                fontFamily: 'Amiri',
                                fontSize: 16.0,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ),
                  ),
                );
              },
            ),
          ),
          
          // Voice interaction controls
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: const BoxDecoration(
              color: Color(0xFFF5F5F5),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                // Status text
                Text(
                  _getStatusText(),
                  style: const TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 18.0,
                    color: Color(0xFF4A7043),
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                ),
                const SizedBox(height: 20),
                
                // Voice button with animation
                GestureDetector(
                  onTap: _isListening || _isSpeaking || _isProcessing 
                    ? null 
                    : _startVoiceInteraction,
                  child: AnimatedBuilder(
                    animation: _isListening ? _waveAnimation : _pulseAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _isListening ? (1.0 + _waveAnimation.value * 0.1) 
                              : _isSpeaking ? _pulseAnimation.value 
                              : 1.0,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: _getButtonColor(),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: _getButtonColor().withOpacity(0.3),
                                spreadRadius: _isListening ? 10 : 5,
                                blurRadius: _isListening ? 20 : 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Icon(
                            _getButtonIcon(),
                            size: 50,
                            color: Colors.white,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                
                // Instruction text
                Text(
                  _getInstructionText(),
                  style: const TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 14.0,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusText() {
    if (_isListening) return 'أستمع إليك...';
    if (_isSpeaking) return 'أتحدث معك...';
    if (_isProcessing) return 'أفكر في الإجابة...';
    return 'اضغط للتحدث معي';
  }

  Color _getButtonColor() {
    if (_isListening) return Colors.red;
    if (_isSpeaking) return Colors.blue;
    if (_isProcessing) return Colors.orange;
    return const Color(0xFF4A7043);
  }

  IconData _getButtonIcon() {
    if (_isListening) return Icons.mic;
    if (_isSpeaking) return Icons.volume_up;
    if (_isProcessing) return Icons.hourglass_empty;
    return Icons.mic_none;
  }

  String _getInstructionText() {
    if (_isListening) return 'تحدث الآن باللغة العربية...';
    if (_isSpeaking) return 'أستمع للإجابة...';
    if (_isProcessing) return 'جاري معالجة طلبك...';
    return 'اضغط على الميكروفون وتحدث عن مشكلتك الطبية';
  }

  @override
  void dispose() {
    _waveController.dispose();
    _pulseController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }
}
