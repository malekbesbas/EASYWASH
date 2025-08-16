import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'location_field.dart';
import 'mainNavigation.dart'; // Restored import

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  String? _googleMapsLink;
  Position? _currentPosition;
  String? _selectedCity;

  final List<String> cities = [
    'بلدية طرابلس المركز',
    'بلدية حي الاندلس',
    'بلدية جنزور',
    'بلدية أبو سليم',
    'بلدية سوق الجمعة',
    'بلدية عين زارة',
    'بلدية تاجوراء',
  ];

  Future<void> _saveUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', _nameController.text);
    await prefs.setString('phone', _phoneController.text);
	
    if (_currentPosition != null) {
      await prefs.setDouble('latitude', _currentPosition!.latitude);
      await prefs.setDouble('longitude', _currentPosition!.longitude);
    }

    if (_googleMapsLink != null) {
      await prefs.setString("google_maps_link", _googleMapsLink!);
    }

    if (_selectedCity != null) {
      await prefs.setString("selectedCity", _selectedCity!);
    }

    await prefs.setBool('loggedIn', true);
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      await _saveUserData();
      // Restored navigation to MainNavigation
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainNavigation()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color.fromARGB(
          255,
          255,
          255,
          255,
        ), // A very light blue for the background
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Original Logo restored
                  Padding(
                    padding: const EdgeInsets.only(bottom: 32.0),
                    child: Image.asset("assets/logo.png", height: 200),
                  ),
                  // Name
                  TextFormField(
                    controller: _nameController,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      labelText: "الاسم",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator:
                        (value) => value!.isEmpty ? "يرجى إدخال الاسم" : null,
                  ),
                  const SizedBox(height: 16),
                  // Phone
                  TextFormField(
                    controller: _phoneController,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: "رقم الهاتف",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "يرجى إدخال رقم الهاتف";
                      }
					  if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
						return "يرجى إدخال أرقام فقط";
						}	
                      if (value.length != 10) {
                        return "رقم الهاتف يجب أن يكون 10 أرقام";
                      }
                      if (!RegExp(r'^09[1-5]').hasMatch(value)) {
                        return "رقم الهاتف يجب أن يبدأ بـ 091 أو 092 أو 093 أو 094 أو 095";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildCityDropdown(),
                  const SizedBox(height: 16),
                  // Location Field
                  LocationField(
                    labelText: "الموقع",
                    hintText: "اضغط على الايقونة    ",
                    onLocationCaptured: _handleLocationCaptured,
                  ),
                  const SizedBox(height: 24),
                  // Submit Button
                  ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text("تسجيل", style: TextStyle(fontSize: 16)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCityDropdown() {
    return DropdownButtonFormField<String>(
      isExpanded: true,
      decoration: InputDecoration(
        labelText: 'المنطقة',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      value: _selectedCity,
      items:
          cities
              .map((city) => DropdownMenuItem(value: city, child: Text(city)))
              .toList(),
      onChanged: (value) {
        setState(() {
          _selectedCity = value;
        });
      },
      validator: (value) => value == null ? 'يرجى اختيار المنطقة' : null,
    );
  }

  void _handleLocationCaptured(Position position, String googleMapsLink) {
    setState(() {
      _currentPosition = position;
      _googleMapsLink = googleMapsLink;
    });
  }
}
