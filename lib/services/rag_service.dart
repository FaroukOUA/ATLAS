import 'dart:convert';
import 'package:flutter/services.dart';

class RAGService {
  static final RAGService _instance = RAGService._internal();
  factory RAGService() => _instance;
  RAGService._internal();

  List<KnowledgeChunk> _knowledgeBase = [];
  bool _isInitialized = false;

  /// Initialize the RAG service by loading and processing the knowledge base
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Load the FirstAidInfo.txt file
      final String content = await rootBundle.loadString('FirstAidInfo.txt');
      _processKnowledgeBase(content);
      _isInitialized = true;
    } catch (e) {
      print('Error initializing RAG service: $e');
      // Fallback to empty knowledge base
      _knowledgeBase = [];
      _isInitialized = true;
    }
  }

  /// Process the knowledge base content into searchable chunks
  void _processKnowledgeBase(String content) {
    _knowledgeBase.clear();
    
    // Split content by chapters/sections
    final sections = content.split('________________________________________');
    
    for (int i = 0; i < sections.length; i++) {
      final section = sections[i].trim();
      if (section.isEmpty) continue;
      
      // Extract chapter title and content
      final lines = section.split('\n');
      String title = '';
      String body = '';
      
      for (int j = 0; j < lines.length; j++) {
        final line = lines[j].trim();
        if (line.isEmpty) continue;
        
        if (j < 2 && (line.startsWith('الفصل') || line.contains(':'))) {
          title = line;
        } else {
          body += line + '\n';
        }
      }
      
      if (title.isNotEmpty && body.isNotEmpty) {
        _knowledgeBase.add(KnowledgeChunk(
          id: 'section_$i',
          title: title,
          content: body.trim(),
          keywords: _extractKeywords(title + ' ' + body),
        ));
      }
    }

    // Add individual procedures as separate chunks
    _addSpecificProcedures();
  }

  /// Add specific medical procedures as separate searchable chunks
  void _addSpecificProcedures() {
    final procedures = [
      KnowledgeChunk(
        id: 'cpr_procedure',
        title: 'الإنعاش القلبي الرئوي (CPR)',
        content: '''
إجراءات الإنعاش القلبي الرئوي:
1. مدّد المصاب على ظهره فوق أرض قاصحة
2. دير 30 ضغطة وسط الصدر (بيديك جوج فوق بعضياتهم)
3. عطيه جوج نَفَسَات (من فمك لفمو ولا فمو لأنفو)
4. بقا عاود 30 ضغطة + 2 نَفَس حتى تجي النجدة
        ''',
        keywords: ['إنعاش', 'قلبي', 'رئوي', 'CPR', 'تنفس', 'قلب', 'ضغطة', 'نفس'],
      ),
      KnowledgeChunk(
        id: 'choking_procedure',
        title: 'التعامل مع الاختناق',
        content: '''
إجراءات التعامل مع الاختناق:
• إلا كان المصاب كيسعل وكيتكلم → خليه يسعل بوحدو
• إلا ما كاينش نفس وما كيتكلمش:
1. وقف ورا المصاب
2. حضنو من تحت الصدر
3. زير بيديك الفوق (حركة هايمليخ)
4. عاود حتى يخرج اللي حاجزو
        ''',
        keywords: ['اختناق', 'هايمليخ', 'سعال', 'تنفس', 'حاجز', 'فم'],
      ),
      KnowledgeChunk(
        id: 'bleeding_procedure',
        title: 'التعامل مع النزيف',
        content: '''
إجراءات التعامل مع النزيف:
النزيف الخارجي:
• ضغط على الجرح بزيف ولا قماش نظيف
• إلا بزاف الدم → رفع العضو الفوق

النزيف الداخلي:
• ما تحركش المصاب
• عيّط للإسعاف دغيا
        ''',
        keywords: ['نزيف', 'دم', 'جرح', 'ضغط', 'زيف', 'قماش'],
      ),
      KnowledgeChunk(
        id: 'burns_procedure',
        title: 'التعامل مع الحروق',
        content: '''
إجراءات التعامل مع الحروق:
• دوز البلاصة المحروقة تحت الماء البارد 10 دقايق
• ما تحطش الزيت ولا الزبدة
• إلا كانت الحرقا كبيرة → غطيها بزيف نظيف وعيط للطبيب
        ''',
        keywords: ['حروق', 'حرق', 'ماء', 'بارد', 'زيت', 'زبدة', 'زيف'],
      ),
      KnowledgeChunk(
        id: 'fractures_procedure',
        title: 'التعامل مع الكسور',
        content: '''
إجراءات التعامل مع الكسور:
• ما تحركش العضم
• ثبت العضو بحوايج ولا خشبة
• عيّط للنجدة
        ''',
        keywords: ['كسور', 'كسر', 'عضم', 'تثبيت', 'خشبة', 'هرس'],
      ),
      KnowledgeChunk(
        id: 'fainting_procedure',
        title: 'التعامل مع الإغماء',
        content: '''
إجراءات التعامل مع الإغماء:
• خلّي المصاب يرقد على ظهرُو
• رفع رجليه الفوق شوية
• منين يفيق عطِيه ما يشرب بشوية
        ''',
        keywords: ['إغماء', 'سخفة', 'رقد', 'رجل', 'فيق', 'شرب'],
      ),
      KnowledgeChunk(
        id: 'bites_stings_procedure',
        title: 'التعامل مع العضات واللسعات',
        content: '''
عضّة الكلب ولا الحيوان:
• غسل البلاصة بالماء والصابون مزيان
• عيّط للطبيب باش يشوف واش خاصك لقاح ضد داء الكلب (السعار)
• غطي الجرح بڤازا نظيف

لسعة العقرب:
• المصاب خاصو يرتاح وما يتحركش بزاف
• حطّ الثلج ولا قماش بارد فوق البلاصة
• ما تمصّش السم وما تحطّيش الزيت ولا مواد أخرى
• عيّط للنجدة باش يدّوه للسبيطار

لسعة النحلة ولا الدبّور:
• شوف واش بقى شوكة فالبلاصة، خرجها ببطء بظفرُك ولا بكارتة
• غسل البلاصة بالماء والصابون
• حطّ ثلج ولا قماش بارد
• إلا بان انتفاخ كبير ولا صعوبة فالتنفس → عيّط فوراً للإسعاف

عضّة الحيّة (الثعبان):
• المصاب يبقى هاني وما يتحركش بزاف باش السم ما يدورش فالدم
• ربط فوق العضّة (شوية ماشي بزاف) باش يبطئ الدوران
• ما تمصّش السم وما تفتحش الجرح
• عيّط للنجدة بسرعة
        ''',
        keywords: ['عضة', 'لسعة', 'كلب', 'عقرب', 'نحلة', 'دبور', 'حية', 'ثعبان', 'سم', 'سعار'],
      ),
    ];

    _knowledgeBase.addAll(procedures);
  }

  /// Extract keywords from Arabic text for better matching
  List<String> _extractKeywords(String text) {
    final keywords = <String>[];
    
    // Common first aid terms in Arabic
    final commonTerms = [
      'إسعاف', 'طبيب', 'مستشفى', 'نجدة', 'مصاب', 'جرح', 'ألم', 'دم', 'نزيف',
      'حرق', 'كسر', 'إغماء', 'تنفس', 'قلب', 'صدر', 'عين', 'يد', 'رجل', 'راس',
      'ماء', 'بارد', 'ساخن', 'نظيف', 'ضغط', 'رفع', 'تثبيت', 'غسل', 'تغطية',
      'عضة', 'لسعة', 'سم', 'حساسية', 'انتفاخ', 'ثلج', 'زيت', 'صابون'
    ];

    // Extract words from text
    final words = text.split(RegExp(r'\s+'));
    for (final word in words) {
      final cleanWord = word.replaceAll(RegExp(r'[^\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF\uFB50-\uFDFF\uFE70-\uFEFF]'), '').trim();
      if (cleanWord.length > 2) {
        keywords.add(cleanWord);
      }
    }

    // Add relevant common terms found in text
    for (final term in commonTerms) {
      if (text.contains(term)) {
        keywords.add(term);
      }
    }

    return keywords.toSet().toList();
  }

  /// Retrieve relevant knowledge chunks based on user query
  List<KnowledgeChunk> retrieveRelevantInfo(String query, {int maxResults = 3}) {
    if (!_isInitialized || _knowledgeBase.isEmpty) {
      return [];
    }

    final queryKeywords = _extractKeywords(query.toLowerCase());
    final scoredChunks = <MapEntry<KnowledgeChunk, double>>[];

    for (final chunk in _knowledgeBase) {
      double score = 0.0;
      
      // Exact title match gets highest score
      if (chunk.title.toLowerCase().contains(query.toLowerCase()) ||
          query.toLowerCase().contains(chunk.title.toLowerCase())) {
        score += 10.0;
      }

      // Content match
      if (chunk.content.toLowerCase().contains(query.toLowerCase())) {
        score += 5.0;
      }

      // Keyword matching
      for (final queryKeyword in queryKeywords) {
        for (final chunkKeyword in chunk.keywords) {
          if (chunkKeyword.toLowerCase().contains(queryKeyword.toLowerCase()) ||
              queryKeyword.toLowerCase().contains(chunkKeyword.toLowerCase())) {
            score += 2.0;
          }
        }
      }

      // Semantic similarity for common medical terms
      score += _calculateSemanticSimilarity(query, chunk);

      if (score > 0) {
        scoredChunks.add(MapEntry(chunk, score));
      }
    }

    // Sort by score and return top results
    scoredChunks.sort((a, b) => b.value.compareTo(a.value));
    return scoredChunks
        .take(maxResults)
        .map((entry) => entry.key)
        .toList();
  }

  /// Calculate semantic similarity for Arabic medical terms
  double _calculateSemanticSimilarity(String query, KnowledgeChunk chunk) {
    double similarity = 0.0;
    
    // Medical term mappings
    final medicalTerms = {
      'حرق': ['حروق', 'محروق', 'احتراق', 'سخون', 'نار'],
      'كسر': ['كسور', 'مكسور', 'هرس', 'عظم', 'عظام'],
      'نزيف': ['دم', 'جرح', 'مجروح', 'قطع'],
      'اختناق': ['تنفس', 'هواء', 'فم', 'حلق'],
      'إغماء': ['سخفة', 'وعي', 'دوخة', 'غيبوبة'],
      'عضة': ['كلب', 'حيوان', 'عض', 'جرح'],
      'لسعة': ['عقرب', 'نحلة', 'دبور', 'سم'],
      'قلب': ['نبض', 'صدر', 'إنعاش', 'CPR'],
      'عين': ['بصر', 'رؤية', 'عمى'],
      'صداع': ['راس', 'رأس', 'ألم'],
    };

    for (final entry in medicalTerms.entries) {
      if (query.contains(entry.key) || chunk.content.contains(entry.key)) {
        for (final synonym in entry.value) {
          if (query.contains(synonym) || chunk.content.contains(synonym)) {
            similarity += 1.0;
          }
        }
      }
    }

    return similarity;
  }

  /// Get all available knowledge chunks (for debugging)
  List<KnowledgeChunk> getAllKnowledge() => _knowledgeBase;

  /// Check if service is initialized
  bool get isInitialized => _isInitialized;
}

class KnowledgeChunk {
  final String id;
  final String title;
  final String content;
  final List<String> keywords;

  KnowledgeChunk({
    required this.id,
    required this.title,
    required this.content,
    required this.keywords,
  });

  @override
  String toString() => 'KnowledgeChunk(id: $id, title: $title)';
}
