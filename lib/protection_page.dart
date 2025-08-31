import 'package:flutter/material.dart';

class ProtectionPage extends StatelessWidget {
  const ProtectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'الحماية',
          style: TextStyle(
            fontFamily: 'Amiri',
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF4A7043),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF4A7043), Color(0xFF6B9B5A)],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _buildSection(
              title: 'حلل الوضعية',
              content: [
                'كاين شي خطر ؟',
                'شكون اللي فخطر ؟',
                'واش نقدر نتحكم فداك الخطر ؟',
              ],
            ),
            _buildSection(
              title: 'حمي',
              content: ['المنقذ (اللي كيساعد)', 'الضحية', 'الشهود'],
            ),
            _buildSection(
              title: 'باش ما يكونش حادث ثاني',
              content: ['بأي وسيلة و/ولا مع شي حد آخر يساعدك.'],
            ),
            _buildWarningSection(),
            _buildSpecialCasesSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required List<String> content}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
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
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Amiri',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4A7043),
            ),
          ),
          const SizedBox(height: 12),
          ...content.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ', style: TextStyle(fontSize: 16)),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 16,
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

  Widget _buildWarningSection() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.orange.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning, color: Colors.orange.shade700),
              const SizedBox(width: 8),
              Text(
                'تحذير مهم',
                style: TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'إلا كان الخطر كبير، كيهدد الحياة، فوري وما نقدرش نتحكمو فيه، خاصنا نديرو إخلاء مستعجل.',
            style: const TextStyle(
              fontFamily: 'Amiri',
              fontSize: 16,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'الإخلاء المستعجل راه حالة استثنائية.\nكنديروها:',
            style: const TextStyle(
              fontFamily: 'Amiri',
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text('• إلا كانت الضحية باينة'),
          const Text('• إلا كان ساهل نوصل ليها'),
        ],
      ),
    );
  }

  Widget _buildSpecialCasesSection() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
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
          const Text(
            'حالات خاصة',
            style: TextStyle(
              fontFamily: 'Amiri',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4A7043),
            ),
          ),
          const SizedBox(height: 16),
          _buildSpecialCase(
            title: 'حادث ديال الطريق',
            items: [
              'إلا كنتي فطوموبيل، شعّل "les feux de détresse" ووقف بعد الحادث.',
              'لبس "gilet fluo" باش تبان.',
              'دير "balise" على 150 حتى لـ200 متر من الجهتين.',
              'ممنوع تشعل دخان.',
              'طفي الكونطاك ديال الطوموبيل.',
              'وخا يكون عندك "extincteur" (طفاية الحريق).',
            ],
          ),
          const Divider(height: 32),
          _buildSpecialCase(
            title: 'تصاور',
            items: [
              'كتشد من رجليه',
              'كتشده من يديه',
              'وقف بعيد على بلاصة الحادث',
              'طفي الكونطاك',
            ],
          ),
          const Divider(height: 32),
          _buildSpecialCase(
            title: 'حادث ديال الكهرباء',
            items: ['طفي الضو قبل ما تقرب للضحية'],
          ),
          const Divider(height: 32),
          _buildSpecialCase(
            title: 'خطر سام (الدخان)',
            items: [
              'إلا كان البلاصة عامرة بالدخان، حبس النفس ديالك',
              'عملية الإنقاذ ما تفوتش 30 ثانية',
            ],
          ),
          const Divider(height: 32),
          _buildSpecialCase(
            title: 'خطر ديال الحريق',
            items: ['غطّي وجهك ويديك وحاول تحمي راسك بلباسك'],
          ),
          const Divider(height: 32),
          _buildSpecialCase(
            title: 'خطر ديال الانفجار بسبب الغاز',
            items: ['بُعد على أي حاجة تقد تولّد الشرارة'],
          ),
          const Divider(height: 32),
          _buildSpecialCase(
            title: 'الحماية ديال الناس إلا كان إنذار',
            items: [
              'الصيرينا كتصوّت بصوت متغيّر لمدة 1 دقيقة و41 ثانية، وكتسكت 5 ثواني، وكتعاود 3 مرات',
              'ملي كيسالي الخطر، كتسمع صوّت واحد ثابت لمدة 30 ثانية',
            ],
          ),
          const Divider(height: 32),
          _buildSpecialCase(
            title: 'الغسيل المستعجل إلا طاح عليك شي منتوج كيميائي',
            items: [
              'استعمل محطة الغسيل ديال العينين ولا الدُوش المستعجل بسرعة',
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSpecialCase({
    required String title,
    required List<String> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Amiri',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF4A7043),
          ),
        ),
        const SizedBox(height: 8),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('• ', style: TextStyle(fontSize: 16)),
                Expanded(
                  child: Text(
                    item,
                    style: const TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
