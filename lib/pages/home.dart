import 'package:easywash/components/carousel.dart';
import 'package:easywash/pages/order.dart';
import 'package:flutter/material.dart';
import 'dart:io'; 
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  final Function(int)? onNavigateToOrder; // Add callback function

  const HomePage({super.key, this.onNavigateToOrder});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String username = '';
  String? _profileImagePath;

  @override
  void initState() {
    super.initState();
    _loadUsername();
  }
    void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('قريبًا ستتوفر الخدمة')),
    );
  }
  @override
void didChangeDependencies() {
  super.didChangeDependencies();
  _loadUsername(); // يعيد تحميل الاسم/الصورة عند كل رجوع
}

Future<void> _loadUsername() async {
  final prefs = await SharedPreferences.getInstance();
  setState(() {
    username = prefs.getString('name') ?? '';
    _profileImagePath = prefs.getString('profile_image_path');
  });
}

String getInitials(String name) {
  final parts = name.trim().split(' ');
  if (parts.isEmpty || parts[0].isEmpty) return '?';
  if (parts.length == 1) return parts[0][0].toUpperCase();
  return parts[0][0].toUpperCase() + parts[1][0].toUpperCase();
}

					Widget _profileHeader() {
  return Container(
    decoration: BoxDecoration(
  color: Colors.white, // تم التعديل هنا
  borderRadius: BorderRadius.circular(30), // تم التعديل هنا
      boxShadow: [
        BoxShadow(
          color: Colors.black12,
          blurRadius: 8,
          offset: Offset(0, 4),
        )
      ],
    ),
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // صورة شخصية دائرية
CircleAvatar(
  radius: 28,
  backgroundColor: Colors.blue.shade300,
  backgroundImage: (_profileImagePath != null && File(_profileImagePath!).existsSync())
      ? FileImage(File(_profileImagePath!))
      : null,
  child: (_profileImagePath == null || !File(_profileImagePath!).existsSync())
      ? Text(
          getInitials(username),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        )
      : null,
),
        const SizedBox(width: 12),
        // نص ترحيبي
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'مرحبًا، $username',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'سعيدون بخدمتك اليوم!',
              style: TextStyle(
                fontSize: 14,
                color: Colors.blue,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}


  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
        backgroundColor: const Color.fromARGB(
          255,
          254,
          255,
          255,
        ), // Light blue background
        ),
        backgroundColor: const Color.fromARGB(
          255,
          254,
          255,
          255,
        ), // Light blue background
        body: SafeArea(
          child: Stack(
            children: [
              // Main scrollable content
              SingleChildScrollView(
                padding: const EdgeInsets.all(20), // Increased overall padding
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Custom AppBar-like section
                    // Welcome & Avatar (modified to be part of the main content)

					
  Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      _profileHeader(),
      const SizedBox(height: 20),
// Banner
                    const BannerCarousel(),
                    const SizedBox(height: 32),
    ],
  ),

                    // Services
                    _sectionHeader('خدماتنا'),
                    const SizedBox(height: 4), // Increased spacing

GridView.count(
  crossAxisCount: 3,
  crossAxisSpacing: 12,
  mainAxisSpacing: 12,
  shrinkWrap: true,
  physics: const NeverScrollableScrollPhysics(),
  // لو حسيت إن الكروت قصيرة/طويلة بدّل childAspectRatio أو استخدم النسخة التالية بـ mainAxisExtent
  childAspectRatio: 0.85,
  children: [
    _serviceCard(
      icon: Icons.local_laundry_service,
      label: 'غسيل الملابس',
      color: const Color(0xFF2196F3),
      onTap: () async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('pending_service', 'clothes');
        widget.onNavigateToOrder?.call(2);
      },
    ),
    _serviceCard(
      imagePath: 'assets/carbet.png',
      label: 'تنظيف السجاد',
      color: const Color(0xFF2196F3),
      onTap: () async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('pending_service', 'carpet');
        widget.onNavigateToOrder?.call(2);
      },
    ),
    _serviceCard(
      icon: Icons.chair,
      label: 'تنظيف الصالونات',
      color: const Color(0xFF2196F3),
      onTap: () async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('pending_service', 'salon');
        widget.onNavigateToOrder?.call(2);
      },
    ),
    _serviceCard(
      icon: Icons.local_car_wash,
      label: 'غسيل سيارات',
      color: const Color(0xFF2196F3),
      onTap: () async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('pending_service', 'carwash');
        widget.onNavigateToOrder?.call(2);
      },
    ),
    _serviceCard(
      icon: Icons.cleaning_services,
      label: 'مدبرة منزل',
      color: const Color(0xFF2196F3),
      onTap: () async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('pending_service', 'maids');
        widget.onNavigateToOrder?.call(2);
      },
    ),
    _serviceCard(
      icon: Icons.shopping_cart,
      label: 'شراء مواد تنظيف',
      color: const Color(0xFF2196F3),
      onTap: () async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('pending_service', 'supplies');
        widget.onNavigateToOrder?.call(2);
      },
    ),
  ],
),
					
                    const SizedBox(height: 20), // Increased spacing
                    // How it works
                    _sectionHeader('كيف يعمل EasyWash؟'),
                    const SizedBox(height: 20), // Increased spacing
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _howItWorksStep(Icons.shopping_bag, 'اختر الخدمة'),
                        _howItWorksStep(Icons.date_range, 'حدد الموعد'),
                        _howItWorksStep(Icons.send, 'أرسل الطلب'),
                      ],
                    ),

                    const SizedBox(height: 120), // for spacing under FAB
                  ],
                ),
              ),
		  ],
        ),
      ),
	),
	);
  }

  Widget _sectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 20, // Even larger font size
        fontWeight: FontWeight.bold,
        color: Colors.blue, // Darker blue for section headers
      ),
    );
  }

  Widget _howItWorksStep(IconData icon, String label) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color.fromARGB(
                  255,
                  104,
                  104,
                  104,
                ).withOpacity(0.2), // Shadow color
                spreadRadius: 2,
                blurRadius: 6,
                offset: Offset(0, 3), // Vertical shadow offset
              ),
            ],
          ),
          child: CircleAvatar(
            radius: 30,
            backgroundColor: const Color.fromARGB(255, 255, 255, 255),
            child: Icon(
              icon,
              color: const Color.fromARGB(255, 40, 143, 228),
              size: 32,
            ),
          ),
        ),

        const SizedBox(height: 12), // Increased spacing
        SizedBox(
          width: 100, // Fixed width for consistent text wrapping
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.blue,
            ), // Larger font and darker blue
          ),
        ),
      ],
    );
  }
}

Widget _serviceCard({
  IconData? icon,
  required String label,
  required Color color,
  String? imagePath,
  VoidCallback? onTap,
}) {
  return SizedBox(
    height: 130, // ارتفاع ثابت للكارت داخل الشبكة
    child: Card(
      clipBehavior: Clip.antiAlias, // السبلَش داخل الحدود
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (imagePath != null)
                SizedBox(
                  height: 48,
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.contain,
                  ),
                )
              else if (icon != null)
                Icon(icon, size: 40, color: color),
              const SizedBox(height: 8),
              // النص لا يخرج خارج الكارت
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: Colors.black87,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

