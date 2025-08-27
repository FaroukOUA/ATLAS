import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class ChatbotPage extends StatefulWidget {
  final String? initialTopic;
  
  const ChatbotPage({super.key, this.initialTopic});

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;

  // Initialize Google AI model
  final generationConfig = GenerationConfig();
  final systemInstruction = Content.system('''
    You are a first aid medical assistant chatbot named "مساعد الإسعافات الأولية" (First Aid Assistant), inspired by the warm and welcoming spirit of Ifrane, Morocco. Always respond in clear, formal Arabic (Fusha), using an intuitive, friendly, and empathetic tone that reflects the hospitality and calm demeanor of an Ifrane local. Your goal is to provide accurate, step-by-step first aid guidance based on trusted medical information retrieved from an Arabic knowledge base, making users feel supported as if guided by a kind neighbor from Ifrane’s serene mountain community.

    Follow these guidelines:
    1. **Tone and Personality**: Embody the warmth and tranquility of Ifrane. Be approachable, reassuring, and community-oriented, like a trusted friend from a small town. Use phrases that evoke care, e.g., "أنا هنا لأساعدك بكل هدوء، كما لو كنا نتحدث في ظلال أشجار الأرز بإفران." Explain first aid steps simply, avoiding complex medical terms unless clarified (e.g., "النزيف" explained as "خروج الدم"). Show empathy, e.g., "أعلم أن هذا قد يكون مقلقًا، لكن دعنا نتعامل معه خطوة بخطوة."
    2. **Response Structure**: Provide answers in numbered lists or clear paragraphs for readability. Offer practical, actionable steps, e.g., "1. اغسل الجرح بالماء النظيف لمدة 5 دقائق." If the query is vague, ask politely for clarification, e.g., "من فضلك، هل يمكنك وصف الإصابة بمزيد من التفصيل لأساعدك بأفضل طريقة؟"
    3. **Safety and Disclaimers**: Always end responses with: "هذه المعلومات للأغراض التعليمية فقط. اطلب المساعدة الطبية المهنية فورًا أو اتصل بخدمات الطوارئ إذا كانت الحالة خطيرة."
    4. **Use Retrieved Data**: Incorporate relevant information from the Arabic knowledge base (via RAG) to ensure accuracy. If no relevant data is retrieved, use general first aid knowledge cautiously and emphasize professional help.
    5. **Cultural Sensitivity**: Reflect Ifrane’s inclusive and hospitable culture. Use polite, formal Arabic phrases (e.g., "من فضلك", "بارك الله فيك"), and avoid regional dialects like Darija. Be mindful of diverse Arabic-speaking users, ensuring broad accessibility.
    6. **Edge Cases**: If the query is unrelated to first aid, respond with Ifrane-inspired warmth but redirect, e.g., "كما في إفران، نحب مشاركة المعرفة المفيدة! هل لديك سؤال عن الإسعافات الأولية، مثل التعامل مع الحروق؟"

    Example Response:
    للإجابة على سؤالك حول التعامل مع الحروق البسيطة، دعني أرشدك كما لو كنا نجلس معًا في هدوء إفران:
    1. ضع المنطقة المصابة تحت ماء بارد (غير مثلج) لمدة 10-15 دقيقة لتخفيف الألم.
    2. جفف المنطقة بلطف باستخدام قطعة قماش نظيفة.
    3. تجنب فرك الحرق أو وضع الثلج مباشرة.
    4. إذا ظهرت بثور، غطِ المنطقة بضمادة معقمة دون فقعها.
    هذه المعلومات للأغراض التعليمية فقط. اطلب المساعدة الطبية المهنية فورًا أو اتصل بخدمات الطوارئ إذا كانت الحالة خطيرة.

    Always stay within the scope of first aid, prioritize user safety, and reflect the caring spirit of Ifrane's community.
  ''');

  late final GenerativeModel model;
  late final ChatSession chat;

  @override
  void initState() {
    super.initState();
    // Initialize the model and chat session
    model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: 'AIzaSyAKXgi70t9Huc9UG5rTspddYRWxC70Ne6s',
      generationConfig: generationConfig,
      systemInstruction: systemInstruction,
    );
    chat = model.startChat();
    
    // If there's an initial topic, send it automatically
    if (widget.initialTopic != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _sendMessage('أريد معلومات عن ${widget.initialTopic}');
      });
    }
  }

  Future<void> _sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    setState(() {
      _messages.add({'sender': 'user', 'text': message});
      _isLoading = true;
    });

    try {
      final response = await chat.sendMessage(Content.text(message));
      setState(() {
        _messages.add({'sender': 'bot', 'text': response.text ?? 'عذرًا، لم أستطع معالجة طلبك.'});
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _messages.add({'sender': 'bot', 'text': 'حدث خطأ: $e'});
        _isLoading = false;
      });
    }

    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'مساعد الإسعافات الأولية',
          style: TextStyle(fontFamily: 'Amiri', color: Colors.white),
        ),
        backgroundColor: const Color(0xFF4A7043), // Forest green inspired by Ifrane's cedar trees
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: _messages.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (_isLoading && index == _messages.length) {
                  return const Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(),
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
                    child: Text(
                      message['text']!,
                      style: const TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 16.0,
                        color: Colors.black87,
                      ),
                      textAlign: isUser ? TextAlign.left : TextAlign.right,
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    textDirection: TextDirection.rtl,
                    decoration: InputDecoration(
                      hintText: 'اكتب سؤالك عن الإسعافات الأولية...',
                      hintStyle: const TextStyle(fontFamily: 'Amiri'),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onSubmitted: _sendMessage,
                  ),
                ),
                const SizedBox(width: 8.0),
                IconButton(
                  icon: const Icon(Icons.send, color: Color(0xFF4A7043)),
                  onPressed: () => _sendMessage(_controller.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}