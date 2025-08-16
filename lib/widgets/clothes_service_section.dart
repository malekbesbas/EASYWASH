import 'package:flutter/material.dart';

/// الأصناف المصنّفة + الأسعار الأساسية (قبل معامل المدينة)
const Map<String, List<Map<String, dynamic>>> _categorizedProducts = {
  ' الملابس العادية': [
    {'name': 'قميص', 'price': 5},
    {'name': 'بنطال', 'price': 7},
    {'name': 'تيشيرت', 'price': 4},
    {'name': 'بلوزة', 'price': 6},
    {'name': 'فستان', 'price': 12},
    {'name': 'تنورة', 'price': 8},
    {'name': 'جاكيت', 'price': 10},
    {'name': 'معطف', 'price': 18},
    {'name': 'بدلة رسمية', 'price': 25},
    {'name': 'ربطة عنق', 'price': 3},
    {'name': 'قميص نوم', 'price': 7},
    {'name': 'شراب', 'price': 1},
    {'name': 'هودي', 'price': 9},
    {'name': 'سترة صوف', 'price': 8},
    {'name': 'بيجامة', 'price': 6},
    {'name': 'شورت', 'price': 4},
    {'name': 'عباءة', 'price': 15},
    {'name': 'جلابية', 'price': 10},
  ],
  ' ملابس الأطفال': [
    {'name': 'قميص طفل', 'price': 3},
    {'name': 'بنطال طفل', 'price': 4},
    {'name': 'فستان طفلة', 'price': 5},
    {'name': 'بيجامة طفل', 'price': 4},
    {'name': 'ملابس رضيع كاملة', 'price': 6},
  ],
  ' الأحذية والحقائب': [
    {'name': 'حذاء رياضي', 'price': 8},
    {'name': 'حذاء رسمي', 'price': 10},
    {'name': 'شبشب منزلي', 'price': 5},
    {'name': 'حقيبة يد صغيرة', 'price': 10},
    {'name': 'حقيبة ظهر', 'price': 15},
    {'name': 'حقيبة سفر', 'price': 25},
  ],
  '️ مفروشات وغرف النوم': [
    {'name': 'ملاءة سرير مفرد', 'price': 10},
    {'name': 'ملاءة سرير مزدوج', 'price': 12},
    {'name': 'غطاء وسادة', 'price': 3},
    {'name': 'بطانية خفيفة', 'price': 15},
    {'name': 'بطانية ثقيلة', 'price': 25},
    {'name': 'مفرش سرير', 'price': 20},
    {'name': 'وسادة', 'price': 6},
    {'name': 'مرتبة صغيرة', 'price': 30},
    {'name': 'مرتبة كبيرة', 'price': 50},
  ],
  ' أغطية وأثاث': [
    {'name': 'غطاء طاولة', 'price': 8},
    {'name': 'غطاء كرسي', 'price': 5},
    {'name': 'مفرش طاولة زينة', 'price': 10},
    {'name': 'غطاء أريكة', 'price': 20},
    {'name': 'كسوة كنبة 3 مقاعد', 'price': 35},
    {'name': 'كسوة كنبة 2 مقاعد', 'price': 25},
  ],
  ' خاصة وموسمية': [
    {'name': 'ملابس عرس', 'price': 50},
    {'name': 'فستان سهرة', 'price': 35},
    {'name': 'بدلة عريس', 'price': 40},
    {'name': 'عباءة فاخرة', 'price': 25},
  ],
  ' متفرقات': [
    {'name': 'شال', 'price': 4},
    {'name': 'قبعة', 'price': 3},
    {'name': 'قفازات', 'price': 3},
    {'name': 'وشاح صوفي', 'price': 5},
  ],
};

/// دالة مساعدة للوصول لسعر الأساس بالاسم
int? productBasePriceByName(String name) {
  for (final cat in _categorizedProducts.values) {
    for (final p in cat) {
      if (p['name'] == name) return p['price'] as int;
    }
  }
  return null;
}

/// واجهة خدمة الملابس (قوائم قابلة للطي + + / -)
class ClothesServiceSection extends StatelessWidget {
  final Map<String, int> selectedItems;
  final void Function(String) onAddItem;
  final void Function(String) onRemoveItem;
  final double cityMultiplier;

  const ClothesServiceSection({
    super.key,
    required this.selectedItems,
    required this.onAddItem,
    required this.onRemoveItem,
    required this.cityMultiplier,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _categorizedProducts.entries.map((entry) {
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 2,
          child: ExpansionTile(
            title: Text(entry.key, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            children: entry.value.map((product) {
              final name = product['name'] as String;
              final basePrice = product['price'] as int;
              final finalPrice = (basePrice * cityMultiplier).round();
              final count = selectedItems[name] ?? 0;
              return ListTile(
                title: Text(name),
                subtitle: Text('$finalPrice د.ل'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(onPressed: () => onRemoveItem(name), icon: const Icon(Icons.remove_circle_outline, color: Colors.red)),
                    Text('$count'),
                    IconButton(onPressed: () => onAddItem(name), icon: const Icon(Icons.add_circle_outline, color: Colors.green)),
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
