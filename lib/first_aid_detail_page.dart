import 'package:flutter/material.dart';
import 'models/first_aid_models.dart';
import 'services/first_aid_service.dart';
import 'widgets/first_aid_widgets.dart';

class FirstAidDetailPage extends StatefulWidget {
  final String topic;

  const FirstAidDetailPage({super.key, required this.topic});

  @override
  State<FirstAidDetailPage> createState() => _FirstAidDetailPageState();
}

class _FirstAidDetailPageState extends State<FirstAidDetailPage> {
  FirstAidData? firstAidData;
  bool isLoading = true;
  Color accentColor = const Color(0xFF4A7043);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final data = await FirstAidService.loadFirstAidData(widget.topic);
    if (mounted) {
      setState(() {
        firstAidData = data;
        isLoading = false;
        if (data != null) {
          accentColor = _parseColor(data.color);
        }
      });
    }
  }

  Color _parseColor(String colorString) {
    try {
      return Color(int.parse(colorString.replaceFirst('#', '0xFF')));
    } catch (e) {
      return const Color(0xFF4A7043);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [accentColor, accentColor.withValues(alpha: 0.8)],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // Header
                _buildHeader(),

                // Content
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(top: 16),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                    ),
                    child:
                        isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : firstAidData == null
                            ? _buildErrorView()
                            : _buildContent(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  firstAidData?.title ?? widget.topic,
                  style: const TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                if (firstAidData?.subtitle != null)
                  Text(
                    firstAidData!.subtitle,
                    style: const TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
              ],
            ),
          ),
          if (firstAidData != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getIconData(firstAidData!.icon),
                color: Colors.white,
                size: 32,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image (optional)
          if (firstAidData!.image.isNotEmpty)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Image.asset(firstAidData!.image, fit: BoxFit.cover),
            ),
          // Description
          if (firstAidData!.description.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              margin: const EdgeInsets.only(bottom: 16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                firstAidData!.description,
                style: const TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 16,
                  color: Color(0xFF424242),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),

          // Warning
          WarningCard(warning: firstAidData!.warning),

          // Assessment (if available)
          if (firstAidData!.assessment != null) _buildAssessmentCard(),

          // Steps
          const SizedBox(height: 16),
          const Text(
            'خطوات الإسعاف',
            style: TextStyle(
              fontFamily: 'Amiri',
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF424242),
            ),
          ),
          const SizedBox(height: 8),

          ...firstAidData!.steps.map(
            (step) => FirstAidStepCard(step: step, accentColor: accentColor),
          ),

          // Warnings
          if (firstAidData!.warnings.isNotEmpty)
            WarningListCard(warnings: firstAidData!.warnings),

          // Emergency call info
          EmergencyCallCard(emergencyCall: firstAidData!.emergencyCall),

          // Additional info sections
          if (firstAidData!.additionalInfo != null) _buildAdditionalSections(),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildAssessmentCard() {
    final assessment = firstAidData!.assessment!;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            assessment.title,
            style: TextStyle(
              fontFamily: 'Amiri',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: accentColor,
            ),
          ),
          const SizedBox(height: 12),
          ...assessment.steps.map(
            (step) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 8.0),
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: accentColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      step,
                      style: const TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 14,
                        color: Color(0xFF424242),
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalSections() {
    final additionalInfo = firstAidData!.additionalInfo!;
    final List<Widget> sections = [];

    // Handle different types of additional sections
    additionalInfo.forEach((key, value) {
      if (key.contains('types') && value is Map<String, dynamic>) {
        sections.add(_buildTypesSection(key, value));
      } else if (key.contains('special') && value is Map<String, dynamic>) {
        sections.add(_buildSpecialCasesSection(key, value));
      }
    });

    return Column(children: sections);
  }

  Widget _buildTypesSection(String key, Map<String, dynamic> data) {
    final title = data['title'] ?? 'معلومات إضافية';
    final types = data['types'] as List<dynamic>? ?? [];

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Amiri',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: accentColor,
            ),
          ),
          const SizedBox(height: 12),
          ...types.map(
            (type) => Container(
              margin: const EdgeInsets.only(bottom: 12.0),
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (type['type'] != null || type['degree'] != null)
                    Text(
                      type['type'] ?? type['degree'] ?? '',
                      style: TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: accentColor,
                      ),
                    ),
                  if (type['description'] != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        type['description'],
                        style: const TextStyle(
                          fontFamily: 'Amiri',
                          fontSize: 14,
                          color: Color(0xFF424242),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecialCasesSection(String key, Map<String, dynamic> data) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            data['title'] ?? 'حالات خاصة',
            style: TextStyle(
              fontFamily: 'Amiri',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: accentColor,
            ),
          ),
          const SizedBox(height: 12),
          ...data.entries.where((e) => e.key != 'title').map((entry) {
            if (entry.value is Map<String, dynamic>) {
              final caseData = entry.value as Map<String, dynamic>;
              return Container(
                margin: const EdgeInsets.only(bottom: 12.0),
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      caseData['title'] ?? entry.key,
                      style: TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: accentColor,
                      ),
                    ),
                    if (caseData['method'] != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          caseData['method'],
                          style: const TextStyle(
                            fontFamily: 'Amiri',
                            fontSize: 14,
                            color: Color(0xFF424242),
                          ),
                        ),
                      ),
                    if (caseData['details'] is List)
                      ...((caseData['details'] as List).map(
                        (detail) => Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(top: 8.0),
                                width: 4,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: accentColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  detail,
                                  style: const TextStyle(
                                    fontFamily: 'Amiri',
                                    fontSize: 14,
                                    color: Color(0xFF424242),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'لم يتم العثور على المعلومات',
            style: TextStyle(
              fontFamily: 'Amiri',
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'يرجى المحاولة مرة أخرى',
            style: TextStyle(
              fontFamily: 'Amiri',
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'favorite':
        return Icons.favorite;
      case 'favorite_border':
        return Icons.favorite_border;
      case 'local_fire_department':
        return Icons.local_fire_department;
      case 'air':
        return Icons.air;
      case 'healing':
        return Icons.healing;
      case 'medical_services':
        return Icons.medical_services;
      case 'bug_report':
        return Icons.bug_report;
      case 'bloodtype':
        return Icons.bloodtype;
      case 'bed':
        return Icons.bed;
      case 'water_drop':
        return Icons.water_drop;
      case 'warning':
        return Icons.warning;
      case 'wb_sunny':
        return Icons.wb_sunny;
      case 'pets':
        return Icons.pets;
      case 'eco':
        return Icons.eco;
      case 'monitor_heart':
        return Icons.monitor_heart;
      case 'flash_on':
        return Icons.flash_on;
      case 'cloud':
        return Icons.cloud;
      case 'psychology':
        return Icons.psychology;
      case 'headset':
        return Icons.headset;
      case 'visibility':
        return Icons.visibility;
      case 'science':
        return Icons.science;
      case 'restaurant':
        return Icons.restaurant;
      case 'ac_unit':
        return Icons.ac_unit;
      case 'water':
        return Icons.water;
      case 'thermostat':
        return Icons.thermostat;
      case 'hearing':
        return Icons.hearing;
      case 'compress':
        return Icons.compress;
      case 'keyboard_arrow_up':
        return Icons.keyboard_arrow_up;
      case 'radio_button_checked':
        return Icons.radio_button_checked;
      case 'wash':
        return Icons.cleaning_services;
      case 'bandage':
        return Icons.healing;
      case 'lock':
        return Icons.lock;
      case 'remove_circle':
        return Icons.remove_circle;
      case 'person':
        return Icons.person;
      case 'refresh':
        return Icons.refresh;
      case 'phone':
        return Icons.phone;
      case 'cake':
        return Icons.cake;
      case 'schedule':
        return Icons.schedule;
      case 'power_settings_new':
        return Icons.power_settings_new;
      case 'security':
        return Icons.security;
      case 'block':
        return Icons.block;
      case 'cleaning_services':
        return Icons.cleaning_services;
      default:
        return Icons.medical_services;
    }
  }
}
