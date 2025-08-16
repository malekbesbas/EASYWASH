import 'package:flutter/material.dart';
import 'package:flip_card/flip_card.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  // List to track which cards are flipped
  List<GlobalKey<FlipCardState>> flipCardKeys = [];
  void _flipOnlyOneCard(int index) {
  for (int i = 0; i < flipCardKeys.length; i++) {
    if (i != index && flipCardKeys[i].currentState?.isFront == false) {
      flipCardKeys[i].currentState?.toggleCard();
    }
  }
  flipCardKeys[index].currentState?.toggleCard();
}

@override
void initState() {
  super.initState();
  // عندك 9 بطاقات: 3 + 3 + 3
  flipCardKeys = List.generate(9, (_) => GlobalKey<FlipCardState>());
}

  // Method to flip back all cards
  void _flipBackAllCards() {
    for (var key in flipCardKeys) {
      if (key.currentState?.isFront == false) {
        key.currentState?.toggleCard();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: GestureDetector(
        // Detect taps anywhere on the screen
        onTap: _flipBackAllCards,
        child: Scaffold(
          appBar: AppBar(
        backgroundColor: const Color.fromARGB(
          255,
          245,
          245,
          245,
        ), // A very light blue for the background
          ),
        backgroundColor: const Color.fromARGB(
          255,
          245,
          245,
          245,
        ), // A very light blue for the background
		body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(vertical: 30.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _sectionTitle('خدماتنا'),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildFlipCard(
							  cardIndex: 0,
                              key: flipCardKeys[0],
                              frontText: 'الملابس',
                              icon: Icons.checkroom,
                              backText:
                                  'خدمات غسيل وتجفيف وكي لجميع أنواع الملابس والاحذية.',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildFlipCard(
							  cardIndex: 1,
                              key: flipCardKeys[1],
                              frontText: 'السجاد',
                              imagePath: 'assets/carbet.png',
                              backText:
                                  'غسيل عميق للسجاد والمفروشات باستخدام معدات عالية الجودة.',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildFlipCard(
							  cardIndex: 2,
                              key: flipCardKeys[2],
                              frontText: 'صالونات',
							  icon: Icons.chair,                          
							  backText:
                                  'تنظيف عميق لصالونات والسجاد والستائر وهما في مكانهم.',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildFlipCard(
							  cardIndex: 3,
                              key: flipCardKeys[3],
                              frontText: 'السيارات',
                              icon: Icons.local_car_wash,
                              backText:
                                  'خدمات غسيل السيارات من الداخل والخارج وانت في مكانك.',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildFlipCard(
							  cardIndex: 4,
                              key: flipCardKeys[4],
                              frontText: 'عاملات النظافة',
                              icon: Icons.cleaning_services,
                              backText:
                                  'نوفر عاملات نظافة عالية الجودة .',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildFlipCard(
							  cardIndex: 5,
                              key: flipCardKeys[5],
                              frontText: 'مواد تنظيف',
							  icon: Icons.shopping_cart,
                              backText:
                                  'نوفر لك كل ما تحتاجه من مواد تنظيف.',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      _sectionTitle('لماذا تختارنا'),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildFlipCard(
							  cardIndex: 6,
                              key: flipCardKeys[6],
                              frontText: 'ضمان الرضا',
                              icon: Icons.verified,
                              backText:
                                  'إذا لم تكن راضيًا، سنعيد تنظيف أغراضك مجانًا.',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildFlipCard(
							  cardIndex: 7,
                              key: flipCardKeys[7],
                              frontText: 'توصيل',
                              icon: Icons.local_shipping,
                              backText: 'خدمة التوصيل والاستلام لعند باب حوشك.',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildFlipCard(
							  cardIndex: 8,
                              key: flipCardKeys[8],
                              frontText: 'خدمة سريعة',
                              icon: Icons.timer,
                              backText:
                                  'استلام خلال أقل من 48 ساعة.',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      sectionCard(
					    title: 'الأسئلة الشائعة',
                        children: [
                          _buildFAQItem(
                            question: 'كم يستغرق تنظيف ملابسي؟',
                            answer:
                                'تستغرق خدمتنا القياس 48 ساعة للغسيل العادي.',
                          ),
                          _buildFAQItem(
                            question:
                                'هل تنظفون الأقمشة الخاصة والعناصر الحساسة؟',
                            answer:
                                'نعم، نتعامل مع جميع أنواع الأقمشة بما في ذلك الحساسة.',
                          ),
                          _buildFAQItem(
                            question: 'كيف تعمل خدمة الاستلام والتوصيل؟',
                            answer:
                                'سائقونا سيأتون لموقعك لجمع وتنظيف وتوصيل أغراضك.',
                          ),
                        ],
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

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Color(0xFF2196F3),
      ),
    );
  }

  // Modified FlipCard builder with manual control
Widget _buildFlipCard({
  required int cardIndex,
  required GlobalKey<FlipCardState> key,
  required String frontText,
  IconData? icon,
  String? imagePath,
  required String backText,
}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: GestureDetector(
        // Prevent the tap from bubbling up to the parent GestureDetector
       onTap: () {
  final index = cardIndex;
  _flipOnlyOneCard(index);
},
        child: FlipCard(
          key: key,
          direction: FlipDirection.HORIZONTAL,
          // Disable automatic flip on tap since we handle it manually
          flipOnTouch: false,
          front: Container(
            height: 140,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (imagePath != null)
                  Image.asset(imagePath, height: 40)
                else if (icon != null)
                  Icon(icon, size: 40, color: Colors.blue),
                const SizedBox(height: 10),
                Text(
                  frontText,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          back: Container(
            height: 140,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Text(
                backText,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14),
                textDirection: TextDirection.rtl,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFAQItem({required String question, required String answer}) {
    return Theme(
      data: ThemeData().copyWith(
        dividerColor: const Color.fromARGB(0, 26, 26, 26),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 12.0),
        childrenPadding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 8.0,
        ),
        title: Text(
          question,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'الإجابة: ',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
              Expanded(
                child: Text(answer, style: const TextStyle(height: 1.4)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget sectionCard({required String title, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 0),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }
}

