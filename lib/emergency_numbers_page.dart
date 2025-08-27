import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:url_launcher/url_launcher.dart';

class EmergencyNumbersPage extends StatelessWidget {
  const EmergencyNumbersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            // Header with back button and title
            Container(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.arrow_back,
                      color: Colors.black87,
                      size: 28,
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      'الطوارئ',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(width: 28), // Balance the back button
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Emergency numbers list
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  children: [
                    _buildEmergencyCard(
                      context,
                      title: 'الشرطة',
                      number: '190',
                      icon: Icons.local_police,
                      color: const Color(0xFF2196F3), // Blue
                      iconBackgroundColor: Colors.white,
                    ),
                    const SizedBox(height: 16),
                    _buildEmergencyCard(
                      context,
                      title: 'الإسعاف',
                      number: '150',
                      icon: Icons.local_hospital,
                      color: const Color(0xFFE53935), // Red
                      iconBackgroundColor: Colors.white,
                    ),
                    const SizedBox(height: 16),
                    _buildEmergencyCard(
                      context,
                      title: 'الوقاية المدنية',
                      number: '15',
                      icon: Icons.fire_truck,
                      color: const Color(0xFFFF7043), // Orange
                      iconBackgroundColor: Colors.white,
                    ),
                    const SizedBox(height: 16),
                    _buildEmergencyCard(
                      context,
                      title: 'إضافة رقم',
                      number: '',
                      icon: Icons.add,
                      color: const Color(0xFF4CAF50), // Green
                      iconBackgroundColor: Colors.white,
                      isAddButton: true,
                    ),
                    const Spacer(),
                    // ATLAS branding at bottom
                    const Padding(
                      padding: EdgeInsets.only(bottom: 20.0),
                      child: Text(
                        'ATLAS',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyCard(BuildContext context, {
    required String title,
    required String number,
    required IconData icon,
    required Color color,
    required Color iconBackgroundColor,
    bool isAddButton = false,
  }) {
    return GestureDetector(
      onTap: () {
        if (isAddButton) {
          _showAddNumberDialog(context);
        } else {
          _showCallDialog(context, title, number);
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: iconBackgroundColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 32,
              ),
            ),
            const SizedBox(width: 20),
            if (!isAddButton) ...[
              Text(
                number,
                style: const TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 20),
            ],
            Expanded(
              child: Text(
                title,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCallDialog(BuildContext context, String service, String number) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'اتصال بـ $service',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Amiri',
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'هل تريد الاتصال بالرقم $number؟',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Amiri',
              fontSize: 16,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'إلغاء',
                style: TextStyle(
                  fontFamily: 'Amiri',
                  color: Colors.grey,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _makePhoneCall(number);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A7043),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'اتصال',
                style: TextStyle(
                  fontFamily: 'Amiri',
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showAddNumberDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController numberController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'إضافة رقم طوارئ جديد',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Amiri',
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                textAlign: TextAlign.right,
                decoration: const InputDecoration(
                  labelText: 'اسم الخدمة',
                  labelStyle: TextStyle(fontFamily: 'Amiri'),
                  border: OutlineInputBorder(),
                ),
                style: const TextStyle(fontFamily: 'Amiri'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: numberController,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'رقم الهاتف',
                  labelStyle: TextStyle(fontFamily: 'Amiri'),
                  border: OutlineInputBorder(),
                ),
                style: const TextStyle(fontFamily: 'Amiri'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'إلغاء',
                style: TextStyle(
                  fontFamily: 'Amiri',
                  color: Colors.grey,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty && numberController.text.isNotEmpty) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'تم حفظ الرقم بنجاح',
                        style: TextStyle(fontFamily: 'Amiri'),
                        textAlign: TextAlign.center,
                      ),
                      backgroundColor: Color(0xFF4A7043),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A7043),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'حفظ',
                style: TextStyle(
                  fontFamily: 'Amiri',
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    
    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      } else {
        // Fallback: Copy number to clipboard
        await Clipboard.setData(ClipboardData(text: phoneNumber));
      }
    } catch (e) {
      // Fallback: Copy number to clipboard
      await Clipboard.setData(ClipboardData(text: phoneNumber));
    }
  }
}

