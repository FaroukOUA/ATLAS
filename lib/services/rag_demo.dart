import 'rag_service.dart';

/// Demo class to showcase RAG functionality
class RAGDemo {
  static final RAGService _ragService = RAGService();

  /// Initialize and demonstrate RAG functionality
  static Future<void> demonstrateRAG() async {
    await _ragService.initialize();
    
    print('=== RAG Demo ===');
    print('Knowledge base initialized with ${_ragService.getAllKnowledge().length} chunks');
    
    // Test queries in Arabic
    final testQueries = [
      'كيفاش ندير CPR؟',
      'واحد كيختانق شنو ندير؟',
      'عندي حرق فيدي',
      'تكسرات لي رجلي',
      'واحد مغمى عليه',
      'قرصني عقرب',
      'عضني كلب',
      'كيفاش نوقف النزيف؟'
    ];

    for (final query in testQueries) {
      print('\n--- Query: $query ---');
      final results = _ragService.retrieveRelevantInfo(query);
      
      if (results.isNotEmpty) {
        print('Found ${results.length} relevant chunks:');
        for (int i = 0; i < results.length; i++) {
          final chunk = results[i];
          print('${i + 1}. ${chunk.title}');
          print('   Content preview: ${chunk.content.substring(0, 100)}...');
        }
      } else {
        print('No relevant information found');
      }
    }
  }

  /// Get sample responses for testing
  static Future<List<String>> getSampleResponses() async {
    await _ragService.initialize();
    
    final queries = [
      'كيفاش ندير الإنعاش القلبي الرئوي؟',
      'واحد كيختانق بالماكلة شنو ندير؟',
      'تحرقت بالزيت السخون',
    ];

    final responses = <String>[];
    for (final query in queries) {
      final relevantInfo = _ragService.retrieveRelevantInfo(query);
      if (relevantInfo.isNotEmpty) {
        String response = 'بناءً على دليل الإسعافات الأولية:\n\n';
        for (final chunk in relevantInfo) {
          response += '${chunk.title}:\n${chunk.content}\n\n';
        }
        responses.add(response);
      }
    }
    
    return responses;
  }
}
