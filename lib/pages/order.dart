import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../widgets/clothes_service_section.dart';
import '../widgets/carpet_service_section.dart';
import '../widgets/home_cleaning_service_section.dart';
import '../widgets/housemaid_service_section.dart';
import '../widgets/car_wash_service_section.dart';
import '../widgets/cleaning_supplies_section.dart';

class OrderPage extends StatefulWidget {
  final String? initialService; // "clothes" | "carpet" | "salon" | "maids" | "carwash" | "supplies"
  const OrderPage({Key? key, this.initialService}) : super(key: key);

  @override
  State<OrderPage> createState() => _OrderPageState();
}

enum ServiceType { clothes, carpet, salon, maids, carwash, supplies }

class _OrderPageState extends State<OrderPage> {
  // نوع الخدمة
  ServiceType? selectedService;

  // حالة الملابس/الأحذية:
  Map<String, int> selectedItems = {}; // من ClothesServiceSection

  // حالة السجاد:
  int carpetCount = 0;

  // حالة تنظيف الصالونات:
  int _homeCleaningUnitPriceFromName(String name) {
  final n = name.trim();
  if (n.contains('كنب') || n.contains('كنبة') || n.contains('أريكة')) return salonSofaPrice;      // د.ل/كنبة
  if (n.contains('غرف') || n.contains('غرفة')) return salonRoomPrice;                               // د.ل/غرفة
  if (n.contains('ستائر')) return salonCurtainM2Price;                                               // د.ل/م²
  return 0; // fallback لو عنصر مش معروف
}
  int salonSofas = 0;      // عدد الكنب
  int salonRooms = 0;      // عدد الغرف
  int salonCurtainsM2 = 0; // أمتار الستائر

  // حالة مدبرة منزل :
  MaidType maidType = MaidType.daily; // من widget
  int maidsCount = 1;
  int maidDays = 1;

  // حالة غسيل السيارات:
  String carType = 'Sedan'; // Sedan/SUV/Van
  int carsCount = 0;

  // حالة شراء مواد:
  Map<String, int> suppliesItems = {};

  // الموعد والموقع
  DateTime? selectedDate;
  String? selectedTimeSlot;
  String? selectedCity;

  String? _googleMapsLink;
  String? _locationText;
  double? _latitude;
  double? _longitude;

  // بيانات واجهة (ثابتة هنا)
  final List<String> timeSlots = const [
    '9:00 - 12:00', '12:00 - 15:00', '15:00 - 18:00', '18:00 - 21:00',
  ];

  final List<String> cities = const [
    'بلدية طرابلس المركز',
    'بلدية حي الاندلس',
    'بلدية جنزور',
    'بلدية أبو سليم',
    'بلدية سوق الجمعة',
    'بلدية عين زارة',
    'بلدية تاجوراء',
  ];

  final Map<String, double> cityPriceMultipliers = const {
    'بلدية طرابلس المركز': 1.4,
    'بلدية حي الاندلس': 1.0,
    'بلدية جنزور': 1.15,
    'بلدية أبو سليم': 1.15,
    'بلدية سوق الجمعة': 1.1,
    'بلدية عين زارة': 1.1,
    'بلدية تاجوراء': 1.2,
  };

  final Map<String, int> cityDeliveryCharges = const {
    'بلدية طرابلس المركز': 10,
    'بلدية حي الاندلس': 15,
    'بلدية جنزور': 20,
    'بلدية أبو سليم': 15,
    'بلدية سوق الجمعة': 15,
    'بلدية عين زارة': 20,
    'بلدية تاجوراء': 20,
  };

  // أسعار أساسية للخدمات الجديدة
  final Map<String,int> carwashBase = const {'Sedan': 40, 'SUV': 50, 'Van': 60}; // د.ل/سيارة
  static const int salonSofaPrice = 30;      // د.ل/كنبة
  static const int salonRoomPrice = 20;      // د.ل/غرفة
  static const int salonCurtainM2Price = 2;  // د.ل/م2
  static const int maidDailyPrice = 120;     // د.ل/عاملة/يوم
  static const int maidLiveInMonthly = 1800; // د.ل/مدبرة/شهر (≈60/يوم)

  final Map<String,int> suppliesBase = const {
    'مسحوق غسيل (5كغ)': 45,
    'منعم أقمشة (2ل)': 30,
    'كلور (4ل)': 25,
    'منظف أرضيات (5ل)': 35,
    'مزيل بقع (1ل)': 28,
  };

  @override
  void initState() {
    super.initState();
    _loadLocationData();
    _loadFormData().then((_) async {
      final prefs = await SharedPreferences.getInstance();
      final pending = prefs.getString('pending_service');
      final svc = (widget.initialService ?? pending);

      switch (svc) {
        case 'clothes': selectedService = ServiceType.clothes; break;
        case 'carpet':  selectedService = ServiceType.carpet;  break;
        case 'salon':   selectedService = ServiceType.salon;   break;
        case 'maids':   selectedService = ServiceType.maids;   break;
        case 'carwash': selectedService = ServiceType.carwash; break;
        case 'supplies':selectedService = ServiceType.supplies;break;
        default:        selectedService = selectedService;      break;
      }
      if (pending != null) await prefs.remove('pending_service');
      setState(() {});
      _saveFormData();
    });
  }

  Future<void> _loadLocationData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _latitude = prefs.getDouble('latitude');
      _longitude = prefs.getDouble('longitude');
      _googleMapsLink = prefs.getString('google_maps_link');
      _locationText = prefs.getString('address');
    });
  }

  Future<void> _loadFormData() async {
    final prefs = await SharedPreferences.getInstance();

    // نوع الخدمة
    final svcStr = prefs.getString('selectedService');
    if (svcStr != null) {
      for (final s in ServiceType.values) {
        if (s.name == svcStr) { selectedService = s; break; }
      }
    }

    // ملابس/أحذية
    selectedItems.clear();
    for (final k in prefs.getKeys().where((k) => k.startsWith('item_'))) {
      final name = k.substring(5);
      final cnt = prefs.getInt(k) ?? 0;
      if (cnt > 0) selectedItems[name] = cnt;
    }

    // سجاد
    carpetCount = prefs.getInt('carpetCount') ?? 0;

    // صالونات
    salonSofas = prefs.getInt('salonSofas') ?? 0;
    salonRooms = prefs.getInt('salonRooms') ?? 0;
    salonCurtainsM2 = prefs.getInt('salonCurtainsM2') ?? 0;

    // مدبرة منزل
    final mt = prefs.getString('maidType');
    if (mt == 'liveIn') maidType = MaidType.liveIn; else maidType = MaidType.daily;
    maidsCount = prefs.getInt('maidsCount') ?? 1;
    maidDays = prefs.getInt('maidDays') ?? 1;

    // سيارات
    carType = prefs.getString('carType') ?? 'Sedan';
    carsCount = prefs.getInt('carsCount') ?? 0;

    // مواد تنظيف
    suppliesItems.clear();
    for (final k in prefs.getKeys().where((k)=> k.startsWith('supplies_'))) {
      final name = k.substring('supplies_'.length);
      final qty = prefs.getInt(k) ?? 0;
      if (qty > 0) suppliesItems[name] = qty;
    }

    // مدينة/وقت/تاريخ
    selectedCity = prefs.getString('selectedCity');
    selectedTimeSlot = prefs.getString('selectedTimeSlot');
    final dateStr = prefs.getString('selectedDate');
    if (dateStr != null) selectedDate = DateTime.tryParse(dateStr);

    setState((){});
  }

  Future<void> _saveFormData() async {
    final prefs = await SharedPreferences.getInstance();

    // نوع الخدمة
    if (selectedService != null) {
      await prefs.setString('selectedService', selectedService!.name);
    }

    // ملابس/أحذية
    for (final k in prefs.getKeys().where((k) => k.startsWith('item_')).toList()) {
      await prefs.remove(k);
    }
    for (final e in selectedItems.entries) {
      await prefs.setInt('item_${e.key}', e.value);
    }

    // سجاد
    await prefs.setInt('carpetCount', carpetCount);

    // صالونات
    await prefs.setInt('salonSofas', salonSofas);
    await prefs.setInt('salonRooms', salonRooms);
    await prefs.setInt('salonCurtainsM2', salonCurtainsM2);

    // مدبرة منزل
    await prefs.setString('maidType', maidType.name);
    await prefs.setInt('maidsCount', maidsCount);
    await prefs.setInt('maidDays', maidDays);

    // سيارات
    await prefs.setString('carType', carType);
    await prefs.setInt('carsCount', carsCount);

    // مواد تنظيف
    for (final k in prefs.getKeys().where((k)=> k.startsWith('supplies_')).toList()) {
      await prefs.remove(k);
    }
    for (final e in suppliesItems.entries) {
      await prefs.setInt('supplies_${e.key}', e.value);
    }

    // مدينة/وقت/تاريخ
    if (selectedCity != null) await prefs.setString('selectedCity', selectedCity!);
    if (selectedTimeSlot != null) await prefs.setString('selectedTimeSlot', selectedTimeSlot!);
    if (selectedDate != null) await prefs.setString('selectedDate', selectedDate!.toIso8601String());
  }

  // ===== حسابات الأسعار =====
  double getCityMultiplier() => cityPriceMultipliers[selectedCity] ?? 1.0;
  int getDeliveryCharge() => selectedCity == null ? 0 : (cityDeliveryCharges[selectedCity] ?? 10);

  int getSubtotal() {
    final m = getCityMultiplier();
    int subtotal = 0;

    switch (selectedService) {
      case ServiceType.clothes:
        for (final name in selectedItems.keys) {
          final base = productBasePriceByName(name) ?? 0;
          final unit = (base * m).round();
          subtotal += unit * (selectedItems[name] ?? 0);
        }
        break;

      case ServiceType.carpet:
        final unit = (15 * m).round();
        subtotal += carpetCount * unit;
        break;

case ServiceType.salon:
  selectedItems.forEach((name, qty) {
    final base = _homeCleaningUnitPriceFromName(name);
    final unit = (base * m).round();
    subtotal += unit * qty;
  });
  break;
      case ServiceType.maids:
        final perDay = maidType == MaidType.daily ? maidDailyPrice : (maidLiveInMonthly / 30);
        subtotal += (perDay * maidsCount * maidDays * m).round();
        break;

      case ServiceType.carwash:
        final unit = ((carwashBase[carType] ?? 0) * m).round();
        subtotal += unit * carsCount;
        break;

      case ServiceType.supplies:
        suppliesItems.forEach((name, qty) {
          final unit = ((suppliesBase[name] ?? 0) * m).round();
          subtotal += unit * qty;
        });
        break;

      default:
        break;
    }

    return subtotal;
  }

  int getTotal() => getSubtotal() + getDeliveryCharge();

  // ===== إرسال الطلب عبر واتساب =====
  Future<void> _submitOrder() async {
    // تحقق من صحة الإدخال حسب نوع الخدمة
    bool valid = false;
  switch (selectedService) {
    case ServiceType.clothes: valid = selectedItems.isNotEmpty; break;
    case ServiceType.carpet:  valid = carpetCount > 0; break;
    case ServiceType.salon:  valid = selectedItems.isNotEmpty; break;
    case ServiceType.maids:   valid = (maidsCount > 0 && maidDays > 0); break;
    case ServiceType.carwash: valid = (carsCount > 0); break;
    case ServiceType.supplies:valid = suppliesItems.isNotEmpty; break;
    default: valid = false; break;
  }
    if (!valid) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('يرجى تحديد تفاصيل الخدمة قبل الإرسال.')));
      return;
    }
    if (selectedDate == null || selectedTimeSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('يرجى اختيار موعد الاستلام .')));
      return;
    }

final subtotal = getSubtotal();
final delivery = getDeliveryCharge();
final total = getTotal();

// بدل String details = '';
final details = StringBuffer();

switch (selectedService) {
  case ServiceType.clothes:
    if (selectedItems.isNotEmpty) {
      details.writeln('\n- الملابس/الأحذية:');
      selectedItems.forEach((name, cnt) {
        final base = productBasePriceByName(name) ?? 0;
        final unit = (base * getCityMultiplier()).round();
        details.writeln('  $name × $cnt = ${unit * cnt} د.ل');
      });
    }
    break;

  case ServiceType.carpet:
    final unit = (15 * getCityMultiplier()).round();
    details.writeln('\n- السجاد: $carpetCount قطعة × $unit د.ل = ${unit * carpetCount} د.ل');
    break;

  case ServiceType.salon:
    final uSofa = (salonSofaPrice * getCityMultiplier()).round();
    final uRoom = (salonRoomPrice * getCityMultiplier()).round();
    final uCur  = (salonCurtainM2Price * getCityMultiplier()).round();
    if (salonSofas > 0)    details.writeln('\n- كنب: $salonSofas × $uSofa = ${salonSofas * uSofa} د.ل');
    if (salonRooms > 0)    details.writeln('\n- غرف: $salonRooms × $uRoom = ${salonRooms * uRoom} د.ل');
    if (salonCurtainsM2>0) details.writeln('\n- ستائر (م²): $salonCurtainsM2 × $uCur = ${salonCurtainsM2 * uCur} د.ل');
    break;

  case ServiceType.maids:
    final perDay = maidType == MaidType.daily
        ? (maidDailyPrice * getCityMultiplier()).round()
        : ((maidLiveInMonthly / 30) * getCityMultiplier()).round();
    final t = maidType == MaidType.daily ? 'يومية' : 'مقيمة (بالأيام)';
    details.writeln('\n- مدبرة منزل ($t): $maidsCount مدبرة × $maidDays يوم × $perDay = ${maidsCount * maidDays * perDay} د.ل');
    break;

  case ServiceType.carwash:
    final unit = ((carwashBase[carType] ?? 0) * getCityMultiplier()).round();
    details.writeln('\n- غسيل سيارات ($carType): $carsCount × $unit = ${carsCount * unit} د.ل');
    break;

  case ServiceType.supplies:
    if (suppliesItems.isNotEmpty) {
      details.writeln('\n- مواد تنظيف:');
      suppliesItems.forEach((name, qty) {
        final unit = ((suppliesBase[name] ?? 0) * getCityMultiplier()).round();
        details.writeln('  $name × $qty = ${unit * qty} د.ل');
      });
    }
    break;

  default:
    break;
}

// انتبه: استخدم toString()
String message =
    'مرحبًا، أود طلب خدمة EasyWash (${selectedService?.name ?? "-"}) :\n'
    '\n══════════════\n'
    '📋 تفاصيل الطلب:\n${details.toString()}\n'
    '\n══════════════\n'
    '🧾 ملخص الفاتورة:\n'
    '- المجموع الفرعي: $subtotal د.ل\n'
    '- رسوم التوصيل (${selectedCity ?? "-"}) : $delivery د.ل\n'
    '- الإجمالي النهائي: $total د.ل\n'
    '\n══════════════\n'
    '📅 معلومات التسليم:\n'
    '- التاريخ: ${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}\n'
    '- الفترة: $selectedTimeSlot\n'
    '- المنطقة: ${selectedCity ?? "-"}';


    if (_locationText != null && _locationText!.isNotEmpty) {
      message += '\n\n- العنوان: $_locationText';
    }
    if (_googleMapsLink != null && _googleMapsLink!.isNotEmpty) {
      message += '\n- رابط الموقع: $_googleMapsLink';
    }

    message += '\n\nشكراً لطلبك من خدمتنا، نتمنى لك يوماً سعيداً.';

    final Uri whatsappUrl = Uri.parse('https://wa.me/218944009444?text=${Uri.encodeComponent(message)}');

    if (await canLaunchUrl(whatsappUrl)) {
      await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);

      // تفريغ الحالة والـ prefs
      setState(() {
        selectedService = null;
        selectedItems.clear();
        carpetCount = 0;
        salonSofas = salonRooms = salonCurtainsM2 = 0;
        maidType = MaidType.daily; maidsCount = 1; maidDays = 1;
        carType = 'Sedan'; carsCount = 0;
        suppliesItems.clear();

        selectedDate = null;
        selectedTimeSlot = null;
        selectedCity = null;
      });

      final prefs = await SharedPreferences.getInstance();
      final keysToRemove = prefs.getKeys().where((k) =>
        k.startsWith('item_') ||
        k.startsWith('supplies_') ||
        [
          'selectedService',
          'carpetCount',
          'salonSofas','salonRooms','salonCurtainsM2',
          'maidType','maidsCount','maidDays',
          'carType','carsCount',
          'selectedCity','selectedTimeSlot','selectedDate',
        ].contains(k)
      ).toList();
      for (final k in keysToRemove) { await prefs.remove(k); }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تعذر فتح واتساب.')));
    }
  }

  // ===== واجهة =====
@override
Widget build(BuildContext context) {
  final m = getCityMultiplier();

  return Directionality(
    textDirection: TextDirection.rtl,
    child: Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F5F5),
      ),
      backgroundColor: const Color(0xFFF5F5F5),

      // ✅ خلي الزر ثابت تحت
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: ElevatedButton.icon(
          onPressed: _submitOrder,
          icon: const Icon(Icons.send, color: Colors.white),
          label: const Text('طلب عبر واتساب', style: TextStyle(fontSize: 18)),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 55),
            backgroundColor: const Color(0xFF1976D2),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 5,
          ),
        ),
      ),

      // ✅ ScrollView نظيف من غير Intrinsic/Constrained/Spacer
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 12),

            // اختيار نوع الخدمة (شبكة)
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.15,
              children: [
                _serviceChip(ServiceType.clothes, 'ملابس/أحذية'),
                _serviceChip(ServiceType.carpet, 'سجاد'),
                _serviceChip(ServiceType.salon, 'تنظيف الصالونات'),
                _serviceChip(ServiceType.carwash, 'غسيل سيارات'),
                _serviceChip(ServiceType.maids, 'مدبرة منزل'),
                _serviceChip(ServiceType.supplies, 'مواد تنظيف'),
              ],
            ),

            const SizedBox(height: 16),

            // الأقسام الشرطية كما هي (بدون تغيير)
            if (selectedService == ServiceType.clothes) ClothesServiceSection(
              selectedItems: selectedItems,
              onAddItem: (name) => setState(() { selectedItems[name] = (selectedItems[name] ?? 0) + 1; _saveFormData(); }),
              onRemoveItem: (name) => setState(() {
                final c = (selectedItems[name] ?? 0) - 1;
                if (c <= 0) { selectedItems.remove(name); } else { selectedItems[name] = c; }
                _saveFormData();
              }),
              cityMultiplier: m,
            ),

            if (selectedService == ServiceType.carpet) CarpetServiceSection(
              count: carpetCount,
              pricePerPiece: (15 * m).round(),
              onInc: () { setState(() => carpetCount++); _saveFormData(); },
              onDec: () { if (carpetCount > 0) { setState(() => carpetCount--); _saveFormData(); } },
            ),

            if (selectedService == ServiceType.salon) HomeCleaningServiceSection(
              selectedItems: selectedItems,
              onAddItem: (name) => setState(() { selectedItems[name] = (selectedItems[name] ?? 0) + 1; _saveFormData(); }),
              onRemoveItem: (name) => setState(() {
                final c = (selectedItems[name] ?? 0) - 1;
                if (c <= 0) { selectedItems.remove(name); } else { selectedItems[name] = c; }
                _saveFormData();
              }),
              cityMultiplier: m,
            ),

            if (selectedService == ServiceType.maids) MaidsServiceSection(
              maidType: maidType,
              maidsCount: maidsCount,
              maidDays: maidDays,
              onMaidTypeChanged: (type) => setState(() { maidType = type; _saveFormData(); }),
              onMaidsCountChanged: (count) => setState(() { maidsCount = count; _saveFormData(); }),
              onMaidDaysChanged: (days) => setState(() { maidDays = days; _saveFormData(); }),
              cityMultiplier: m,
            ),

            if (selectedService == ServiceType.carwash) CarwashServiceSection(
              carType: carType,
              carsCount: carsCount,
              unitPrice: ((carwashBase[carType] ?? 0) * m).round(),
              onCarTypeChanged: (type) => setState(() { carType = type; _saveFormData(); }),
              onCarsCountChanged: (count) => setState(() { carsCount = count; _saveFormData(); }),
            ),

            if (selectedService == ServiceType.supplies) CleaningSuppliesSection(
              selectedItems: suppliesItems,
              onAddItem: (name) => setState(() { suppliesItems[name] = (suppliesItems[name] ?? 0) + 1; _saveFormData(); }),
              onRemoveItem: (name) => setState(() {
                final c = (suppliesItems[name] ?? 0) - 1;
                if (c <= 0) { suppliesItems.remove(name); } else { suppliesItems[name] = c; }
                _saveFormData();
              }),
              cityMultiplier: m,
            ),

            const SizedBox(height: 10),

            // التاريخ والفترة (من غير IntrinsicHeight)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate ?? DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 30)),
                      );
                      if (picked != null) {
                        setState(() => selectedDate = picked);
                        _saveFormData();
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue.shade200, width: 1.5),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today, color: Colors.blue.shade700),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              selectedDate == null
                                  ? 'اختر التاريخ'
                                  : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
                              style: TextStyle(
                                fontSize: 15,
                                color: selectedDate == null ? Colors.blue.shade700 : Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: 'اختر الفترة الزمنية',
                      labelStyle: TextStyle(color: Colors.blue.shade700),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.blue.shade200, width: 1.5),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                        borderSide: BorderSide(color: Color(0xFF1976D2), width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    ),
                    value: selectedTimeSlot,
                    items: timeSlots.map((s) => DropdownMenuItem(value: s, child: Text(s, overflow: TextOverflow.ellipsis))).toList(),
                    onChanged: (v) { setState(() => selectedTimeSlot = v); _saveFormData(); },
                    icon: Icon(Icons.arrow_drop_down, color: Colors.blue.shade700),
                    dropdownColor: Colors.white,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // الملخص
            Card(
              color: Colors.white,
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('الملخص', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue.shade800)),
                    const SizedBox(height: 12),

                    if (selectedService == ServiceType.clothes && selectedItems.isNotEmpty)
                      ...selectedItems.entries.map((e) {
                        final base = productBasePriceByName(e.key) ?? 0;
                        final unit = (base * m).round();
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(child: Text('${e.key} × ${e.value}', style: const TextStyle(fontSize: 15))),
                              Text('${unit * e.value} د.ل', style: const TextStyle(fontSize: 15)),
                            ],
                          ),
                        );
                      }),

                    if (selectedService == ServiceType.carpet && carpetCount > 0)
                      _rowKV('السجاد', '${(15*m).round() * carpetCount} د.ل'),

                    if (selectedService == ServiceType.salon && selectedItems.isNotEmpty)
                      ...selectedItems.entries.map((e) {
                        final unit = (_homeCleaningUnitPriceFromName(e.key) * m).round();
                        return _rowKV(e.key, '${e.value} × $unit = ${e.value * unit}');
                      }),

                    if (selectedService == ServiceType.maids)
                      _rowKV('مدبرة منزل',
                        '${maidType==MaidType.daily ? "يومية" : "مقيمة"}: '
                        '$maidsCount × $maidDays × '
                        '${((maidType==MaidType.daily ? maidDailyPrice : maidLiveInMonthly/30) * m).round()}'),

                    if (selectedService == ServiceType.carwash && carsCount>0)
                      _rowKV('غسيل سيارات ($carType)', '$carsCount × ${((carwashBase[carType]??0)*m).round()}'),

                    if (selectedService == ServiceType.supplies && suppliesItems.isNotEmpty)
                      ...suppliesItems.entries.map((e){
                        final unit = ((suppliesBase[e.key] ?? 0) * m).round();
                        return _rowKV(e.key, '${e.value} × $unit');
                      }),

                    const Divider(height: 24, thickness: 1.5, color: Colors.blueGrey),
                    _rowTotal('المجموع الفرعي:', getSubtotal()),
                    const SizedBox(height: 8),
                    _rowTotal('رسوم التوصيل${selectedCity != null ? ' ($selectedCity)' : ''}:', getDeliveryCharge()),
                    const SizedBox(height: 8),
                    const Divider(height: 16, thickness: 1, color: Colors.blueGrey),
                    _rowTotal('الإجمالي النهائي:', getTotal(), bold: true, big: true),
                  ],
                ),
              ),
            ),

            // مسافة صغيرة أسفل آخر عنصر (عشان ما يلتصق بالزر السفلي)
            const SizedBox(height: 120),
          ],
        ),
      ),
    ),
  );
}


  // شريحة اختيار خدمة
Widget _serviceChip(ServiceType type, String label) {
  final isSelected = selectedService == type;

  return InkWell(
    onTap: () {
      setState(() => selectedService = type);
      _saveFormData();
    },
    borderRadius: BorderRadius.circular(16),
    child: Card(
      elevation: isSelected ? 8 : 2,
      color: isSelected ? const Color(0xFF42A5F5) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isSelected ? Colors.transparent : Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : Colors.black87,
            ),
          ),
        ),
      ),
    ),
  );
}


  // عناصر ملخص
  Widget _rowKV(String k, String v) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Expanded(child: Text(k)), Text(v)],
      ),
    );
  }

  Widget _rowTotal(String title, int value, {bool bold = false, bool big = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: TextStyle(fontSize: big ? 18 : 16, fontWeight: bold ? FontWeight.bold : FontWeight.normal, color: bold ? Colors.blue.shade900 : Colors.grey.shade700)),
        Text('$value د.ل', style: TextStyle(fontSize: big ? 18 : 16, fontWeight: bold ? FontWeight.bold : FontWeight.normal, color: bold ? Colors.blue.shade900 : Colors.grey.shade700)),
      ],
    );
  }
}
