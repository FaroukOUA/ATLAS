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
                        'ATLAS',
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
              
              // Page title
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                child: Text(
                  'قائمة الإسعافات',
                  style: TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
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
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Search bar
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.search,
                              color: Colors.grey,
                              size: 24,
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'ابحث هنا',
                                style: TextStyle(
                                  fontFamily: 'Amiri',
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                                textAlign: TextAlign.right,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // First aid categories list
                      Expanded(
                        child: ListView(
                          children: [
                            _buildFirstAidCard(
                              context,
                              icon: Icons.favorite,
                              title: 'الإنعاش القلبي',
                              subtitle: 'إرشادات الإنعاش القلبي الرئوي',
                              onTap: () => _navigateToDetail(context, 'الإنعاش القلبي'),
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
                              title: 'الكسور',
                              subtitle: 'إسعاف الكسور والإصابات',
                              onTap: () => _navigateToDetail(context, 'الكسور'),
                            ),
                            const SizedBox(height: 12),
                            _buildFirstAidCard(
                              context,
                              icon: Icons.bug_report,
                              title: 'لسعات العقارب',
                              subtitle: 'التعامل مع لسعات العقارب والثعابين',
                              onTap: () => _navigateToDetail(context, 'لسعات العقارب'),
                            ),
                            const SizedBox(height: 12),
                            _buildFirstAidCard(
                              context,
                              icon: Icons.medical_services,
                              title: 'الجروح',
                              subtitle: 'تنظيف وتطهير الجروح',
                              onTap: () => _navigateToDetail(context, 'الجروح'),
                            ),
                            const SizedBox(height: 12),
                            _buildFirstAidCard(
                              context,
                              icon: Icons.air,
                              title: 'الاختناق',
                              subtitle: 'إسعاف حالات الاختناق',
                              onTap: () => _navigateToDetail(context, 'الاختناق'),
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

  Widget _buildFirstAidCard(BuildContext context, {
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
              color: Colors.grey.withOpacity(0.1),
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
              child: Icon(
                icon,
                color: Colors.white,
                size: 24,
              ),
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
      MaterialPageRoute(
        builder: (context) => FirstAidDetailPage(topic: topic),
      ),
    );
  }
}
