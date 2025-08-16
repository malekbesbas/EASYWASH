import 'package:flutter/material.dart';

/// عناصر "مواد التنظيف" المصنّفة مع السعر الأساسي ووحدة البيع.
/// ملاحظة: السعر هنا "قبل" معامل المدينة. الواجهة تستقبل cityMultiplier وتعرض السعر النهائي/وحدة.
const Map<String, List<Map<String, dynamic>>> _suppliesCatalog = {
  ' منظفات الغسيل': [
    {'name': 'مسحوق غسيل (2 كجم)', 'price': 22, 'unit': 'عبوة'},
    {'name': 'سائل غسيل (2 لتر)', 'price': 26, 'unit': 'عبوة'},
    {'name': 'مُنعم أقمشة (1 لتر)', 'price': 18, 'unit': 'عبوة'},
    {'name': 'مُبيض / كلور (1 لتر)', 'price': 8,  'unit': 'عبوة'},
    {'name': 'مُزيل بقع (500 مل)', 'price': 14,  'unit': 'عبوة'},
  ],

  ' مطهرات ومعقمات': [
    {'name': 'مطهر عام (1 لتر)', 'price': 15, 'unit': 'عبوة'},
    {'name': 'معقم مركز (5 لتر)', 'price': 60, 'unit': 'جالون'},
    {'name': 'معقم يدين (500 مل)', 'price': 10, 'unit': 'عبوة'},
  ],

  ' تنظيف المطبخ': [
    {'name': 'سائل جلي (1 لتر)', 'price': 9,  'unit': 'عبوة'},
    {'name': 'منظف دهون قوي (750 مل)', 'price': 16, 'unit': 'عبوة'},
    {'name': 'إسفنجة جلي (3 قطع)', 'price': 6,  'unit': 'طقم'},
    {'name': 'قماش مايكروفايبر (5 قطع)', 'price': 18, 'unit': 'طقم'},
  ],

  ' تنظيف الأرضيات والأسطح': [
    {'name': 'منظف أرضيات (2 لتر)', 'price': 20, 'unit': 'عبوة'},
    {'name': 'ممسحة/رأس ماب', 'price': 14, 'unit': 'قطعة'},
    {'name': 'مقشة أرضيات', 'price': 12, 'unit': 'قطعة'},
    {'name': 'ممّسحة زجاج (سكيجي)', 'price': 10, 'unit': 'قطعة'},
  ],

  ' زجاج وحمام': [
    {'name': 'منظف زجاج (750 مل)', 'price': 10, 'unit': 'عبوة'},
    {'name': 'منظف حمام/جير (750 مل)', 'price': 14, 'unit': 'عبوة'},
    {'name': 'فرشاة حمام', 'price': 9, 'unit': 'قطعة'},
  ],

  ' قفازات وأكياس ومعطرات': [
    {'name': 'قفازات مطاط (متوسط)', 'price': 7,  'unit': 'زوج'},
    {'name': 'أكياس قمامة (30 قطعة)', 'price': 12, 'unit': 'رول'},
    {'name': 'معطر جو (300 مل)', 'price': 9,  'unit': 'عبوة'},
  ],
};

/// يعيد السعر الأساسي قبل المعامل حسب الاسم
int? suppliesBasePriceByName(String name) {
  for (final cat in _suppliesCatalog.values) {
    for (final p in cat) {
      if (p['name'] == name) return p['price'] as int;
    }
  }
  return null;
}

/// يعيد وحدة البيع (عبوة/جالون/قطعة...) حسب الاسم
String? suppliesUnitByName(String name) {
  for (final cat in _suppliesCatalog.values) {
    for (final p in cat) {
      if (p['name'] == name) return p['unit'] as String;
    }
  }
  return null;
}

/// واجهة شراء مواد التنظيف (مشابهة لملف غسيل الملابس):
/// - تعرض القوائم المصنّفة
/// - لكل صنف: سعر نهائي بعد المعامل + عدادات +/-
/// - تستخدم selectedItems (Map<اسم, كمية>) التي تُدار من الصفحة الرئيسية
class CleaningSuppliesSection extends StatelessWidget {
  final Map<String, int> selectedItems;
  final void Function(String) onAddItem;
  final void Function(String) onRemoveItem;
  final double cityMultiplier;

  const CleaningSuppliesSection({
    super.key,
    required this.selectedItems,
    required this.onAddItem,
    required this.onRemoveItem,
    required this.cityMultiplier,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _suppliesCatalog.entries.map((entry) {
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 2,
          child: ExpansionTile(
            title: Text(
              entry.key,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            children: entry.value.map((product) {
              final name = product['name'] as String;
              final basePrice = product['price'] as int;
              final unit = product['unit'] as String;
              final finalUnitPrice = (basePrice * cityMultiplier).round();
              final count = selectedItems[name] ?? 0;

              return ListTile(
                title: Text(name),
                subtitle: Text('$finalUnitPrice د.ل / $unit'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () => onRemoveItem(name),
                      icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                    ),
                    Text('$count'),
                    IconButton(
                      onPressed: () => onAddItem(name),
                      icon: const Icon(Icons.add_circle_outline, color: Colors.green),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }
}
