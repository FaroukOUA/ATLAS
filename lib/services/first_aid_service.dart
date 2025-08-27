import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/first_aid_models.dart';

class FirstAidService {
  static const String _basePath = 'assets/first_aid_data/';
  
  static const Map<String, String> _fileMap = {
    'الإنعاش القلبي': 'cpr.json',
    'الحروق': 'burns.json',
    'الاختناق': 'choking.json',
    'الكسور': 'fractures.json',
    'الجروح': 'wounds.json',
    'لسعات العقارب': 'scorpion_stings.json',
  };

  static Future<FirstAidData?> loadFirstAidData(String topic) async {
    try {
      final fileName = _fileMap[topic];
      if (fileName == null) return null;
      
      final String jsonString = await rootBundle.loadString('$_basePath$fileName');
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      
      return FirstAidData.fromJson(jsonData);
    } catch (e) {
      print('Error loading first aid data for $topic: $e');
      return null;
    }
  }

  static Future<List<FirstAidData>> loadAllFirstAidData() async {
    final List<FirstAidData> allData = [];
    
    for (final fileName in _fileMap.values) {
      try {
        final String jsonString = await rootBundle.loadString('$_basePath$fileName');
        final Map<String, dynamic> jsonData = json.decode(jsonString);
        allData.add(FirstAidData.fromJson(jsonData));
      } catch (e) {
        print('Error loading $fileName: $e');
      }
    }
    
    return allData;
  }

  static String? getFileNameForTopic(String topic) {
    return _fileMap[topic];
  }
  
  static List<String> getAllTopics() {
    return _fileMap.keys.toList();
  }
}

