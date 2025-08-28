import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import '../models/first_aid_models.dart';

class FirstAidService {
  static const String _basePath = 'assets/first_aid_data/';

  static const Map<String, String> _fileMap = {
    'الاختناق': 'choking.json',
    'النزيف بزاف': 'bleeding.json',
    'فاقد الوعي وكيتنفس': 'cpr.json',
    'فاقد الوعي وما كيتنفسش': 'cpr.json',
    'الحروق': 'burns.json',
    'الجروح': 'wounds.json',
    'الكسور': 'fractures.json',
    'الغرق': 'drowning.json',
    'التسمم': 'poisoning.json',
    'ضربة الشمس': 'heatstroke.json',
    'لسعة العقرب': 'scorpion_stings.json',
    'قرصة الأفعى': 'snake_bite.json',
    'لسعة النحل': 'bee_sting.json',
    'أزمة الربو': 'asthma.json',
    'أزمة السكر (هبوط)': 'diabetes.json',
    'أزمة القلب': 'heart_attack.json',
    'الكهرباء': 'electric_shock.json',
    'التسمم بالغاز': 'gas_poisoning.json',
    'التشنجات (الصرع)': 'seizures.json',
    'ضربة على الراس': 'head_injury.json',
    'العين دخل فيها جسم غريب': 'eye_injury.json',
    'مواد كيميائية فالعين': 'chemical_eye.json',
    'تسمم غذائي': 'food_poisoning.json',
    'انخفاض الحرارة': 'hypothermia.json',
    'لسعة البحر': 'jellyfish_sting.json',
    'الحمى المفاجئة': 'fever.json',
    'نزيف من الفم ولا الأذن': 'ear_mouth_bleeding.json',
  };

  static Future<FirstAidData?> loadFirstAidData(String topic) async {
    try {
      final fileName = _fileMap[topic];
      if (fileName == null) return null;

      final String jsonString = await rootBundle.loadString(
        '$_basePath$fileName',
      );
      final Map<String, dynamic> jsonData = json.decode(jsonString);

      return FirstAidData.fromJson(jsonData);
    } catch (e) {
      debugPrint('Error loading first aid data for $topic: $e');
      return null;
    }
  }

  static Future<List<FirstAidData>> loadAllFirstAidData() async {
    final List<FirstAidData> allData = [];

    for (final fileName in _fileMap.values) {
      try {
        final String jsonString = await rootBundle.loadString(
          '$_basePath$fileName',
        );
        final Map<String, dynamic> jsonData = json.decode(jsonString);
        allData.add(FirstAidData.fromJson(jsonData));
      } catch (e) {
        debugPrint('Error loading $fileName: $e');
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
