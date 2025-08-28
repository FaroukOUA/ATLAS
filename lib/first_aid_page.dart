import 'package:flutter/material.dart';
import 'first_aid_detail_page.dart';

class FirstAidPage extends StatelessWidget {
  const FirstAidPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF4A7043), // Forest green
              Color(0xFF6B9B5A), // Lighter green
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header with back button and title
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const Expanded(
                      child: Text(
                        'قائمة الإسعافات',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Amiri',
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 28), // Balance the back button
                  ],
                ),
              ),

              // Seasonal Emergency Cases Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5.0),
                child: Row(
                  children: [
                    // Summer Cases (Yellow Box)
                    Expanded(
                      child: _buildSeasonalBox(
                        context: context,
                        title: 'صيف',
                        backgroundColor: const Color(0xFFE8B84A),
                        iconColor: Colors.white,
                        textColor: Colors.white,
                        cases: [
                          EmergencyCase('لسعة العقرب', Icons.bug_report),
                          EmergencyCase('قرصة الأفعى', Icons.pets),
                          EmergencyCase('الغرق', Icons.water_drop),
                        ],
                      ),
                    ),
                    const SizedBox(width: 5),
                    // Winter Cases (Blue Box)
                    Expanded(
                      child: _buildSeasonalBox(
                        context: context,
                        title: 'الشتاء',
                        backgroundColor: const Color(0xFF4A90A4),
                        iconColor: Colors.white,
                        textColor: Colors.white,
                        cases: [
                          EmergencyCase('انخفاض الحرارة', Icons.ac_unit),
                          EmergencyCase('الجروح', Icons.bloodtype),
                          EmergencyCase('أزمة القلب', Icons.monitor_heart),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Main content container
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(16.0),
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),

                      // All first aid categories list
                      const Text(
                        'جميع حالات الطوارئ',
                        style: TextStyle(
                          fontFamily: 'Amiri',
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF424242),
                        ),
                      ),
                      const SizedBox(height: 16),

                      Expanded(
                        child: ListView(
                          children: [
                            _buildFirstAidCard(
                              context,
                              icon: Icons.air,
                              title: 'الاختناق',
                              subtitle: 'إسعاف حالات الاختناق',
                              onTap:
                                  () => _navigateToDetail(context, 'الاختناق'),
                            ),
                            const SizedBox(height: 12),
                            _buildFirstAidCard(
                              context,
                              icon: Icons.bloodtype,
                              title: 'النزيف بزاف',
                              subtitle: 'إسعاف حالات النزيف الشديد',
                              onTap:
                                  () =>
                                      _navigateToDetail(context, 'النزيف بزاف'),
                            ),
                            const SizedBox(height: 12),
                            _buildFirstAidCard(
                              context,
                              icon: Icons.favorite,
                              title: 'فاقد الوعي وكيتنفس',
                              subtitle: 'إسعاف فاقد الوعي مع التنفس',
                              onTap:
                                  () => _navigateToDetail(
                                    context,
                                    'فاقد الوعي وكيتنفس',
                                  ),
                            ),
                            const SizedBox(height: 12),
                            _buildFirstAidCard(
                              context,
                              icon: Icons.favorite_border,
                              title: 'فاقد الوعي وما كيتنفسش',
                              subtitle: 'إسعاف فاقد الوعي بدون تنفس',
                              onTap:
                                  () => _navigateToDetail(
                                    context,
                                    'فاقد الوعي وما كيتنفسش',
                                  ),
                            ),
                            const SizedBox(height: 12),
                            _buildFirstAidCard(
                              context,
                              icon: Icons.local_fire_department,
                              title: 'الحروق',
                              subtitle: 'كيفية التعامل مع الحروق',
                              onTap: () => _navigateToDetail(context, 'الحروق'),
                            ),
                            const SizedBox(height: 12),
                            _buildFirstAidCard(
                              context,
                              icon: Icons.healing,
                              title: 'الجروح',
                              subtitle: 'تنظيف وتطهير الجروح',
                              onTap: () => _navigateToDetail(context, 'الجروح'),
                            ),
                            const SizedBox(height: 12),
                            _buildFirstAidCard(
                              context,
                              icon: Icons.healing,
                              title: 'الحروق',
                              subtitle: 'الحروق لجروح',
                              onTap: () => _navigateToDetail(context, 'الحروق'),
                            ),
                            const SizedBox(height: 12),
                            _buildFirstAidCard(
                              context,
                              icon: Icons.medical_services,
                              title: 'الكسور',
                              subtitle: 'إسعاف الكسور والإصابات',
                              onTap: () => _navigateToDetail(context, 'الكسور'),
                            ),
                            const SizedBox(height: 12),
                            _buildFirstAidCard(
                              context,
                              icon: Icons.water_drop,
                              title: 'الغرق',
                              subtitle: 'إسعاف حالات الغرق',
                              onTap: () => _navigateToDetail(context, 'الغرق'),
                            ),
                            const SizedBox(height: 12),
                            _buildFirstAidCard(
                              context,
                              icon: Icons.warning,
                              title: 'التسمم',
                              subtitle: 'إسعاف حالات التسمم',
                              onTap: () => _navigateToDetail(context, 'التسمم'),
                            ),
                            const SizedBox(height: 12),
                            _buildFirstAidCard(
                              context,
                              icon: Icons.wb_sunny,
                              title: 'ضربة الشمس',
                              subtitle: 'إسعاف ضربة الشمس',
                              onTap:
                                  () =>
                                      _navigateToDetail(context, 'ضربة الشمس'),
                            ),
                            const SizedBox(height: 12),
                            _buildFirstAidCard(
                              context,
                              icon: Icons.bug_report,
                              title: 'لسعة العقرب',
                              subtitle: 'التعامل مع لسعات العقارب',
                              onTap:
                                  () =>
                                      _navigateToDetail(context, 'لسعة العقرب'),
                            ),
                            const SizedBox(height: 12),
                            _buildFirstAidCard(
                              context,
                              icon: Icons.pets,
                              title: 'قرصة الأفعى',
                              subtitle: 'إسعاف عضات الأفاعي',
                              onTap:
                                  () =>
                                      _navigateToDetail(context, 'قرصة الأفعى'),
                            ),
                            const SizedBox(height: 12),
                            _buildFirstAidCard(
                              context,
                              icon: Icons.eco,
                              title: 'لسعة النحل',
                              subtitle: 'إسعاف لسعات النحل والدبابير',
                              onTap:
                                  () =>
                                      _navigateToDetail(context, 'لسعة النحل'),
                            ),
                            const SizedBox(height: 12),
                            _buildFirstAidCard(
                              context,
                              icon: Icons.air,
                              title: 'أزمة الربو',
                              subtitle: 'إسعاف نوبات الربو',
                              onTap:
                                  () =>
                                      _navigateToDetail(context, 'أزمة الربو'),
                            ),
                            const SizedBox(height: 12),
                            _buildFirstAidCard(
                              context,
                              icon: Icons.monitor_heart,
                              title: 'أزمة السكر (هبوط)',
                              subtitle: 'إسعاف هبوط السكر',
                              onTap:
                                  () => _navigateToDetail(
                                    context,
                                    'أزمة السكر (هبوط)',
                                  ),
                            ),
                            const SizedBox(height: 12),
                            _buildFirstAidCard(
                              context,
                              icon: Icons.favorite,
                              title: 'أزمة القلب',
                              subtitle: 'إسعاف النوبات القلبية',
                              onTap:
                                  () =>
                                      _navigateToDetail(context, 'أزمة القلب'),
                            ),
                            const SizedBox(height: 12),
                            _buildFirstAidCard(
                              context,
                              icon: Icons.flash_on,
                              title: 'الكهرباء',
                              subtitle: 'إسعاف الصدمات الكهربائية',
                              onTap:
                                  () => _navigateToDetail(context, 'الكهرباء'),
                            ),
                            const SizedBox(height: 12),
                            _buildFirstAidCard(
                              context,
                              icon: Icons.cloud,
                              title: 'التسمم بالغاز',
                              subtitle: 'إسعاف التسمم بالغاز',
                              onTap:
                                  () => _navigateToDetail(
                                    context,
                                    'التسمم بالغاز',
                                  ),
                            ),
                            const SizedBox(height: 12),
                            _buildFirstAidCard(
                              context,
                              icon: Icons.psychology,
                              title: 'التشنجات (الصرع)',
                              subtitle: 'إسعاف نوبات التشنج',
                              onTap:
                                  () => _navigateToDetail(
                                    context,
                                    'التشنجات (الصرع)',
                                  ),
                            ),
                            const SizedBox(height: 12),
                            _buildFirstAidCard(
                              context,
                              icon: Icons.headset,
                              title: 'ضربة على الراس',
                              subtitle: 'إسعاف إصابات الرأس',
                              onTap:
                                  () => _navigateToDetail(
                                    context,
                                    'ضربة على الراس',
                                  ),
                            ),
                            const SizedBox(height: 12),
                            _buildFirstAidCard(
                              context,
                              icon: Icons.visibility,
                              title: 'العين دخل فيها جسم غريب',
                              subtitle: 'إسعاف إصابات العين',
                              onTap:
                                  () => _navigateToDetail(
                                    context,
                                    'العين دخل فيها جسم غريب',
                                  ),
                            ),
                            const SizedBox(height: 12),
                            _buildFirstAidCard(
                              context,
                              icon: Icons.science,
                              title: 'مواد كيميائية فالعين',
                              subtitle: 'إسعاف المواد الكيميائية في العين',
                              onTap:
                                  () => _navigateToDetail(
                                    context,
                                    'مواد كيميائية فالعين',
                                  ),
                            ),
                            const SizedBox(height: 12),
                            _buildFirstAidCard(
                              context,
                              icon: Icons.restaurant,
                              title: 'تسمم غذائي',
                              subtitle: 'إسعاف التسمم الغذائي',
                              onTap:
                                  () =>
                                      _navigateToDetail(context, 'تسمم غذائي'),
                            ),
                            const SizedBox(height: 12),
                            _buildFirstAidCard(
                              context,
                              icon: Icons.ac_unit,
                              title: 'انخفاض الحرارة',
                              subtitle: 'إسعاف انخفاض الحرارة',
                              onTap:
                                  () => _navigateToDetail(
                                    context,
                                    'انخفاض الحرارة',
                                  ),
                            ),
                            const SizedBox(height: 12),
                            _buildFirstAidCard(
                              context,
                              icon: Icons.water,
                              title: 'لسعة البحر',
                              subtitle: 'إسعاف لسعات قنديل البحر',
                              onTap:
                                  () =>
                                      _navigateToDetail(context, 'لسعة البحر'),
                            ),
                            const SizedBox(height: 12),
                            _buildFirstAidCard(
                              context,
                              icon: Icons.thermostat,
                              title: 'الحمى المفاجئة',
                              subtitle: 'إسعاف الحمى العالية',
                              onTap:
                                  () => _navigateToDetail(
                                    context,
                                    'الحمى المفاجئة',
                                  ),
                            ),
                            const SizedBox(height: 12),
                            _buildFirstAidCard(
                              context,
                              icon: Icons.hearing,
                              title: 'نزيف من الفم ولا الأذن',
                              subtitle: 'إسعاف نزيف الفم والأذن',
                              onTap:
                                  () => _navigateToDetail(
                                    context,
                                    'نزيف من الفم ولا الأذن',
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSeasonalBox({
    required BuildContext context,
    required String title,
    required Color backgroundColor,
    required Color iconColor,
    required Color textColor,
    required List<EmergencyCase> cases,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Season Title
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Amiri',
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 20),
          // Emergency Cases
          ...cases.map(
            (emergencyCase) => _buildEmergencyItem(
              context,
              emergencyCase.name,
              emergencyCase.icon,
              iconColor,
              textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyItem(
    BuildContext context,
    String title,
    IconData icon,
    Color iconColor,
    Color textColor,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _navigateToDetail(context, title),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFirstAidCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF4A7043),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.right,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey.shade400,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToDetail(BuildContext context, String topic) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FirstAidDetailPage(topic: topic)),
    );
  }
}

class EmergencyCase {
  final String name;
  final IconData icon;

  EmergencyCase(this.name, this.icon);
}
