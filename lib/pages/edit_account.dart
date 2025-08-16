import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'location_service.dart';
import 'location_utils.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class EditAccountPage extends StatefulWidget {
  const EditAccountPage({super.key});

  @override
  State<EditAccountPage> createState() => _EditAccountPageState();
}

class _EditAccountPageState extends State<EditAccountPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _address = TextEditingController();
  String? _city;

  // الموقع / خرائط
  Position? _currentPosition;
  String? _googleMapsLink;

  // الصورة
  String? _profileImagePath;
  final ImagePicker _picker = ImagePicker();

  final List<String> _cities = const [
    'بلدية طرابلس المركز',
    'بلدية حي الاندلس',
    'بلدية جنزور',
    'بلدية أبو سليم',
    'بلدية سوق الجمعة',
    'بلدية عين زارة',
    'بلدية تاجوراء',
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    _name.text = p.getString('name') ?? '';
    _phone.text = p.getString('phone') ?? '';
    _address.text = p.getString('address') ?? '';
	_googleMapsLink = p.getString('google_maps_link');
    _city = p.getString('selectedCity');
    _profileImagePath = p.getString('profile_image_path');
    setState(() {});
  }

Future<void> _save() async {
  if (!_formKey.currentState!.validate()) return;
  final p = await SharedPreferences.getInstance();

  // الاسم والهاتف
  await p.setString('name', _name.text.trim());
  await p.setString('phone', _phone.text.trim());

  // العنوان النصّي
  final addr = _address.text.trim(); // ← استخدم المتحكم الصحيح
  if (addr.isNotEmpty) {
    await p.setString('address', addr);
  } else {
    await p.remove('address');
  }

  // الإحداثيات + رابط الخرائط
  final pos = _currentPosition; // Position?
  if (pos != null) {
    await p.setDouble('latitude', pos.latitude);
    await p.setDouble('longitude', pos.longitude);
    await p.setString(
      'google_maps_link',
      _googleMapsLink ?? 'https://maps.google.com/?q=${pos.latitude},${pos.longitude}',
    );
  } else if (_googleMapsLink != null) {
    // في حال عندك رابط بدون Position
    await p.setString('google_maps_link', _googleMapsLink!);
  } else {
    await p.remove('google_maps_link');
  }

  // تنظيف مفتاح قديم إن وُجد
  await p.remove('position');

  // المنطقة
  if (_city != null) await p.setString('selectedCity', _city!);

  // الصورة
  if (_profileImagePath != null) {
    await p.setString('profile_image_path', _profileImagePath!);
  } else {
    await p.remove('profile_image_path');
  }

  if (mounted) Navigator.pop(context, true);
}


  Future<void> _pickImageFrom(ImageSource source) async {
    final XFile? img = await _picker.pickImage(
      source: source,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );
    if (img != null) {
      setState(() => _profileImagePath = img.path);
    }
  }

  void _showImageSheet() {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('اختيار من المعرض'),
              onTap: () {
                Navigator.pop(context);
                _pickImageFrom(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('التقاط صورة'),
              onTap: () {
                Navigator.pop(context);
                _pickImageFrom(ImageSource.camera);
              },
            ),
            if (_profileImagePath != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('حذف الصورة', style: TextStyle(color: Colors.red)),
                onTap: () {
                  setState(() => _profileImagePath = null);
                  Navigator.pop(context);
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _getCurrentLocation() async {
    try {
      final position = await LocationService.getCurrentLocation();
      if (position != null) {
        setState(() {
          _currentPosition = position;
          _googleMapsLink = LocationUtils.generateGoogleMapsLink(
            position.latitude,
            position.longitude,
          );
          _address.text = LocationUtils.formatLocationForDisplay(
            position.latitude,
            position.longitude,
          );
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم الحصول على الموقع بنجاح!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('فشل في الحصول على الموقع. تأكد من تفعيل خدمات الموقع والسماح بالوصول.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ أثناء الحصول على الموقع: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('تعديل البيانات', style: TextStyle(color: Colors.white)),
          backgroundColor: const Color(0xFF1976D2),
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // صورة البروفايل
              Center(
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: _showImageSheet,
                      borderRadius: BorderRadius.circular(48),
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          CircleAvatar(
                            radius: 48,
                            backgroundImage: (_profileImagePath != null && File(_profileImagePath!).existsSync())
                                ? FileImage(File(_profileImagePath!))
                                : null,
                            child: (_profileImagePath == null)
                                ? const Icon(Icons.person, size: 48)
                                : null,
                          ),
                          Container(
                            margin: const EdgeInsets.only(right: 2, bottom: 2),
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Color(0xFF1976D2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.edit, size: 16, color: Colors.white),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),
                  ],
                ),
              ),

              // الاسم
              TextFormField(
                controller: _name,
                textAlign: TextAlign.center,
                decoration: const InputDecoration(labelText: 'الاسم الكامل'),
                validator: (v) => (v == null || v.isEmpty) ? 'يرجى إدخال الاسم' : null,
              ),
              const SizedBox(height: 12),

              // الهاتف
              TextFormField(
                controller: _phone,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
                decoration: const InputDecoration(labelText: 'رقم الهاتف'),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'يرجى إدخال رقم الهاتف';
                  if (v.length != 10) return 'رقم الهاتف يجب أن يكون 10 أرقام';
                  if (!RegExp(r'^09[1-5]').hasMatch(v)) return 'يبدأ بـ 091/092/093/094/095';
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // المنطقة
              DropdownButtonFormField<String>(
                value: _city,
                isExpanded: true,
                items: _cities.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (v) => setState(() => _city = v),
                decoration: const InputDecoration(labelText: 'المنطقة'),
                validator: (v) => v == null ? 'يرجى اختيار المنطقة' : null,
              ),
              const SizedBox(height: 12),

              // العنوان + أزرار الخرائط
              TextFormField(
                controller: _address,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  labelText: 'العنوان',
                  hintText: 'اكتب العنوان أو حدده من الموقع',
                  suffixIcon: _googleMapsLink != null
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.map),
                              tooltip: 'فتح في خرائط جوجل',
onPressed: () async {
  final Uri uri = Uri.parse(_googleMapsLink!);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
},                            ),
                            IconButton(
                              icon: const Icon(Icons.copy),
                              tooltip: 'نسخ رابط الموقع',
                              onPressed: () {
                                Clipboard.setData(ClipboardData(text: _googleMapsLink!));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('تم نسخ رابط الموقع!'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              },
                            ),
                          ],
                        )
                      : null,
                ),
                validator: (v) => (v == null || v.isEmpty) ? 'يرجى إدخال العنوان' : null,
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.center,
                child: ElevatedButton.icon(
                  onPressed: _getCurrentLocation,
                  icon: const Icon(Icons.my_location),
                  label: const Text('تحديد الموقع الحالي'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1976D2),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // حفظ
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1976D2),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('حفظ'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  @override
void dispose() {
  _name.dispose();
  _phone.dispose();
  _address.dispose();
  super.dispose();
}
}
