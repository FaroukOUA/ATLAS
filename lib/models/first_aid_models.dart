class FirstAidData {
  final String id;
  final String title;
  final String subtitle;
  final String icon;
  final String color;
  final String description;
  final WarningInfo warning;
  final List<FirstAidStep> steps;
  final List<String> warnings;
  final EmergencyCallInfo emergencyCall;
  final AssessmentInfo? assessment;
  final Map<String, dynamic>? specialCases;
  final Map<String, dynamic>? additionalInfo;

  FirstAidData({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.description,
    required this.warning,
    required this.steps,
    required this.warnings,
    required this.emergencyCall,
    this.assessment,
    this.specialCases,
    this.additionalInfo,
  });

  factory FirstAidData.fromJson(Map<String, dynamic> json) {
    return FirstAidData(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      subtitle: json['subtitle'] ?? '',
      icon: json['icon'] ?? 'medical_services',
      color: json['color'] ?? '#4CAF50',
      description: json['description'] ?? '',
      warning: WarningInfo.fromJson(json['warning'] ?? {}),
      steps: (json['steps'] as List<dynamic>?)
          ?.map((step) => FirstAidStep.fromJson(step))
          .toList() ?? [],
      warnings: List<String>.from(json['warnings'] ?? []),
      emergencyCall: EmergencyCallInfo.fromJson(json['emergency_call'] ?? {}),
      assessment: json['assessment'] != null 
          ? AssessmentInfo.fromJson(json['assessment'])
          : null,
      specialCases: json['special_cases'],
      additionalInfo: json,
    );
  }
}

class FirstAidStep {
  final int step;
  final String title;
  final String description;
  final String icon;
  final List<String> details;

  FirstAidStep({
    required this.step,
    required this.title,
    required this.description,
    required this.icon,
    required this.details,
  });

  factory FirstAidStep.fromJson(Map<String, dynamic> json) {
    return FirstAidStep(
      step: json['step'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      icon: json['icon'] ?? 'medical_services',
      details: List<String>.from(json['details'] ?? []),
    );
  }
}

class WarningInfo {
  final String title;
  final String text;

  WarningInfo({
    required this.title,
    required this.text,
  });

  factory WarningInfo.fromJson(Map<String, dynamic> json) {
    return WarningInfo(
      title: json['title'] ?? 'تحذير',
      text: json['text'] ?? '',
    );
  }
}

class EmergencyCallInfo {
  final String title;
  final List<String> conditions;
  final String number;

  EmergencyCallInfo({
    required this.title,
    required this.conditions,
    required this.number,
  });

  factory EmergencyCallInfo.fromJson(Map<String, dynamic> json) {
    return EmergencyCallInfo(
      title: json['title'] ?? 'متى تتصل بالإسعاف',
      conditions: List<String>.from(json['conditions'] ?? []),
      number: json['number'] ?? '150',
    );
  }
}

class AssessmentInfo {
  final String title;
  final List<String> steps;

  AssessmentInfo({
    required this.title,
    required this.steps,
  });

  factory AssessmentInfo.fromJson(Map<String, dynamic> json) {
    return AssessmentInfo(
      title: json['title'] ?? 'التقييم الأولي',
      steps: List<String>.from(json['steps'] ?? []),
    );
  }
}

