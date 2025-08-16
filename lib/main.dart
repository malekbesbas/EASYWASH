import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pages/signup.dart';
import 'pages/mainNavigation.dart';

void main() {
  runApp(const EasyWashApp());
}

class EasyWashApp extends StatelessWidget {
  const EasyWashApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EASYWASH',
      theme: ThemeData(primarySwatch: Colors.blue, fontFamily: 'Tajawal'),
      home: const LandingPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  bool? isLoggedIn;

  @override
  void initState() {
    super.initState();
    checkLoginStatus();
  }

  void checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final loggedIn = prefs.getBool('loggedIn') ?? false;
    setState(() {
      isLoggedIn = loggedIn;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoggedIn == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return isLoggedIn! ? const MainNavigation() : const SignupPage();
  }
}
