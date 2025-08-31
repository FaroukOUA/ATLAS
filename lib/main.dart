import 'package:flutter/material.dart';
import 'emergency_button.dart';
import 'chatbot_page.dart';
import 'first_aid_page.dart';
import 'emergency_numbers_page.dart';
import 'voice_chat_page.dart';
import 'nearby_hospitals_page.dart';
import 'protection_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'أطلس - التطبيق الطبي',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        fontFamily: 'Amiri',
        useMaterial3: true,
      ),
      home: const MyHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

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
              // Header with app title
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  'ATLAS Care',
                  style: TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 36,
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
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Emergency section with functional button
                      EmergencyButton(),

                      const SizedBox(height: 30),

                      // Service buttons grid
                      Expanded(
                        child: GridView.count(
                          crossAxisCount: 2,
                          crossAxisSpacing: 15,
                          mainAxisSpacing: 15,
                          childAspectRatio: 0.9,
                          children: [
                            _buildServiceCard(
                              context,
                              icon: Icons.medical_services,
                              title: 'إسعافات أولية',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const FirstAidPage(),
                                  ),
                                );
                              },
                            ),
                            _buildServiceCard(
                              context,
                              icon: Icons.phone,
                              title: 'أرقام الطوارئ',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const EmergencyNumbersPage(),
                                  ),
                                );
                              },
                            ),
                            _buildServiceCard(
                              context,
                              icon: Icons.pin_drop,
                              title: 'المستشفيات القريبة',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const NearbyHospitalsPage(),
                                  ),
                                );
                              },
                            ),
                            _buildServiceCard(
                              context,
                              icon: Icons.chat,
                              title: 'المحادثة الذكية',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const ChatbotPage(),
                                  ),
                                );
                              },
                            ),
                            _buildServiceCard(
                              context,
                              icon: Icons.security,
                              title: 'الحماية',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const ProtectionPage(),
                                  ),
                                );
                              },
                            ),
                            _buildServiceCard(
                              context,
                              icon: Icons.mic,
                              title: 'المحادثة الصوتية',
                              subtitle: 'تحدث بالعربية',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const VoiceChatPage()),
                                );
                              },
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

  Widget _buildServiceCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF4A7043),
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF4A7043).withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: const Color(0xFF4A7043), size: 35),
              ),
              const SizedBox(height: 15),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 5),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}