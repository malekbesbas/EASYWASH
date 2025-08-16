// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'signup.dart';
import 'edit_account.dart';
import 'TermsandConditions.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
   
String _name = '';
String _phone = '';
String? _avatarUrl;
String? _profileImagePath;

Future<void> _loadProfile() async {
  final prefs = await SharedPreferences.getInstance();
  setState(() {
    _name = prefs.getString('name') ?? '';
    _phone = prefs.getString('phone') ?? '';
    _avatarUrl = prefs.getString('avatarUrl'); // لو ما تخزنهاش عادي تبقى null
  });
}

  @override
  void initState() {
    super.initState();
    _loadUserData();
	  _loadProfile();

  }

Future<void> _loadUserData() async {
  final prefs = await SharedPreferences.getInstance();
  _profileImagePath = prefs.getString("profile_image_path");
  setState(() {}); // تحديث الأفاتار
}

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clears all saved data including 'loggedIn'

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const SignupPage()),
      (route) => false,
    );
  }

Future<void> _openWhatsApp() async {
  final phone = _phone.isNotEmpty ? _phone : '0910000000'; // رقم للتواصل (عدّله)
  final msg = Uri.encodeComponent('مرحبًا، أريد الاستفسار عن EasyWash');
  final uri = Uri.parse('https://wa.me/$phone?text=$msg');
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('لا يمكن فتح واتساب'), backgroundColor: Colors.red),
    );
  }
}

Widget _plainSetting({
  required IconData icon,
  required String title,
  Color? iconColor,
  Color? textColor,
  VoidCallback? onTap,
}) {
  return InkWell(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, color: iconColor ?? const Color(0xFF6B7280)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: textColor ?? const Color(0xFF111827),
              ),
            ),
          ),
          const Icon(Icons.chevron_left, color: Color(0xFF9CA3AF), size: 22),
        ],
      ),
    ),
  );
}

Widget _contactAndSocial(BuildContext context) {

  return Column(
    children: [
      const SizedBox(height: 16),
      Text('للاشتراك او الاستفسار', style: TextStyle(color: Colors.grey[600])),
      const SizedBox(height: 16),
      SizedBox(
        width: 200,
        child: ElevatedButton.icon(
onPressed: _openWhatsApp,
          icon: const Icon(Icons.chat_bubble_outline),
          label: const Text('تواصل معنا'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            padding: const EdgeInsets.symmetric(vertical: 16),
            elevation: 0,
          ),
        ),
      ),
      const SizedBox(height: 16),
      Text('تابعنا على', style: TextStyle(color: Colors.grey[600])),
      const SizedBox(height: 16),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.facebook), color: Colors.blue, iconSize: 40),
          IconButton(onPressed: () {}, icon: const Icon(Icons.camera_alt), color: Colors.blue, iconSize: 40),
        ],
      ),
      const SizedBox(height: 24),
    ],
  );
}

Widget _accountHeader(String name, String phone, {String? avatarUrl}) {
  ImageProvider? avatarImage;

  // صورة محلية من SharedPreferences
  if (_profileImagePath != null && File(_profileImagePath!).existsSync()) {
    avatarImage = FileImage(File(_profileImagePath!));
  } else if (avatarUrl != null && avatarUrl.isNotEmpty) {
    // أو صورة شبكة (اختياري)
    avatarImage = NetworkImage(avatarUrl);
  }

  return Column(
    children: [
      const SizedBox(height: 30),
      CircleAvatar(
        radius: 44,
        backgroundImage: avatarImage,
        child: avatarImage == null ? const Icon(Icons.person, size: 44) : null,
      ),
      const SizedBox(height: 10),
      Text(name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
      const SizedBox(height: 4),
      Text(phone, style: const TextStyle(fontSize: 15, color: Color(0xFF6B7280))),
      const SizedBox(height: 12),
    ],
  );
}

@override
Widget build(BuildContext context) {
  return Directionality(
    textDirection: TextDirection.rtl,
    child: Scaffold(
        backgroundColor: const Color.fromARGB(
          255,
          245,
          245,
          245,
        ), // A very light blue for the background
		
	          appBar: AppBar(
        backgroundColor: const Color.fromARGB(
          255,
          245,
          245,
          245,
        ), // A very light blue for the background
        ),


      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _accountHeader(_name, _phone, avatarUrl: _avatarUrl),

            // عناصر الإعدادات (شفافة، بدون حواف/تقسيم)
_plainSetting(
  icon: Icons.person_outline,
  title: 'تغيير البيانات',
  iconColor: Colors.blue,
  onTap: () async {
final changed = await Navigator.push(
  context,
  MaterialPageRoute(builder: (_) => const EditAccountPage()),
);
if (changed == true) {
  await _loadUserData();  // عشان تجيب مسار الصورة الجديد
  await _loadProfile();   // الاسم/الهاتف
  setState(() {});
}
  },
),

_plainSetting(
  icon: Icons.description_outlined,
  title: 'الشروط والأحكام',
  iconColor: Colors.blue,
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const TermsandConditionsPage()),
    );
  },
),
_plainSetting(
  icon: Icons.logout,
  title: 'تسجيل خروج',
  textColor: const Color(0xFFEF4444),
  iconColor: const Color(0xFFEF4444),
  onTap: _logout, // ← استخدم الدالة الموجودة
),

            _contactAndSocial(context),
          ],
        ),
      ),
    ),
  );
}
}

