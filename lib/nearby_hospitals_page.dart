import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class NearbyHospitalsPage extends StatelessWidget {
  const NearbyHospitalsPage({super.key});

  Future<void> _openGoogleMapsSearch(BuildContext context) async {
    // Try native geo: URI (opens installed maps apps)
    final Uri geoUri = Uri.parse(
      'geo:0,0?q=%D9%85%D8%B3%D8%AA%D8%B4%D9%81%D9%89',
    );

    // Try Google Maps app scheme
    final Uri gmapsAppUri = Uri.parse(
      'comgooglemaps://?q=%D9%85%D8%B3%D8%AA%D8%B4%D9%81%D9%89',
    );

    // Fallback to HTTPS which opens in browser/Maps
    final Uri httpsUri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=%D9%85%D8%B3%D8%AA%D8%B4%D9%81%D9%89+%D9%82%D8%B1%D9%8A%D8%A8+%D9%85%D9%86%D9%8A',
    );

    Future<bool> tryLaunch(
      Uri uri, {
      LaunchMode mode = LaunchMode.externalApplication,
    }) async {
      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri, mode: mode);
      }
      return false;
    }

    final bool launched =
        await tryLaunch(geoUri) ||
        await tryLaunch(gmapsAppUri) ||
        await tryLaunch(httpsUri);

    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تعذر فتح خرائط جوجل على هذا الجهاز')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'المستشفيات القريبة',
          style: TextStyle(fontFamily: 'Amiri', color: Colors.white),
        ),
        backgroundColor: const Color(0xFF4A7043),
        centerTitle: true,
      ),
      body: Container(
        color: const Color(0xFFE6F0EA),
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'ابحث عن أقرب مستشفى',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'انقر على الزر لفتح خرائط جوجل والبحث عن المستشفيات القريبة منك مباشرةً.',
                    textAlign: TextAlign.right,
                    style: TextStyle(fontFamily: 'Amiri', fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4A7043),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () => _openGoogleMapsSearch(context),
                    icon: const Icon(Icons.map),
                    label: const Text(
                      'افتح في خرائط جوجل',
                      style: TextStyle(fontFamily: 'Amiri', fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Text(
                'ملاحظة: قد تحتاج لتفعيل خدمة الموقع على هاتفك للحصول على نتائج دقيقة.',
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
