import 'package:flutter/material.dart';
import 'home.dart';
import 'about.dart';
import 'order.dart';
import 'account.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  _MainNavigationState createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  // Create a method to handle navigation from HomePage
  void _navigateToTab(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Updated to pass the navigation callback to HomePage
  List<Widget> get _pages => <Widget>[
    HomePage(onNavigateToOrder: _navigateToTab), // Pass callback to HomePage
    AboutPage(),
    OrderPage(),
    AccountPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'الصفحة الرئيسية'),
          BottomNavigationBarItem(icon: Icon(Icons.info), label: 'من نحن'),
          BottomNavigationBarItem(icon: Icon(Icons.local_laundry_service), label: 'طلب الخدمة'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'حسابي'),
        ],
      ),
    );
  }
}

