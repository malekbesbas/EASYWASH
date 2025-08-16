import 'package:flutter/material.dart';

/// عناصر تنظيف المنازل (صالونات/سجاد/ستائر) وأسعارها الأساسية قبل معامل المدينة.
/// ملاحظة: بعض العناصر مسعّرة "بالقطعة"، وبعضها "بالمتر المربع (م²)"، وبعضها "بالمتر الطولي (م)".
const Map<String, List<Map<String, dynamic>>> _homeCleaningProducts = {
  ' تنظيف الصالونات (المفروشات)': [
    {'name': 'كنبة ثلاثية المقاعد', 'price': 35, 'unit': 'قطعة'},
    {'name': 'كنبة ثنائية المقاعد', 'price': 25, 'unit': 'قطعة'},
    {'name': 'ركنة (L-Shape) كبيرة', 'price': 60, 'unit': 'قطعة'},
    {'name': 'كرسي مفرد/فوتيه', 'price': 12, 'unit': 'قطعة'},
    {'name': 'مجموعة طقم صالون كاملة', 'price': 110, 'unit': 'طقم'},
    {'name': 'مفروشات جلد (قطعة)', 'price': 20, 'unit': 'قطعة'},
    {'name': 'مفروشات مخمل/قطيفة (قطعة)', 'price': 15, 'unit': 'قطعة'},
  ],

  ' تنظيف السجاد المنزلي': [
    {'name': 'سجاد منزلي (حتى 2×3م)', 'price': 30, 'unit': 'قطعة'},
    {'name': 'سجاد كبير (أكبر من 2×3م)', 'price': 45, 'unit': 'قطعة'},
    {'name': 'سجادة صلاة/ممر', 'price': 10, 'unit': 'قطعة'},
    {'name': 'سجاد بالمتر المربع', 'price': 6,  'unit': 'م²'},
  ],

  ' تنظيف الستائر': [
    {'name': 'ستارة خفيفة (فوال) بالمتر', 'price': 4,  'unit': 'م'},
    {'name': 'ستارة ثقيلة (بلاك آوت) بالمتر', 'price': 6,  'unit': 'م'},
    {'name': 'ستارة مزدوجة (خفيفة+ثقيلة) بالمتر', 'price': 9,  'unit': 'م'},
    {'name': 'ستارة رول/بلاك آوت قطعة', 'price': 20, 'unit': 'قطعة'},
  ],
};

/// إرجاع السعر الأساسي قبل معامل المدينة حسب الاسم
int? homeCleaningBasePriceByName(String name) {
  for (final cat in _homeCleaningProducts.values) {
    for (final p in cat) {
      if (p['name'] == name) return p['price'] as int;
    }
  }
  return null;
}

/// إرجاع وحدة القياس (قطعة/م²/م/طقم) للعنصر
String? homeCleaningUnitByName(String name) {
  for (final cat in _homeCleaningProducts.values) {
    for (final p in cat) {
      if (p['name'] == name) return p['unit'] as String;
    }
  }
  return null;
}

/// واجهة خدمة "تنظيف الصالونات والسجاد والستائر"
/// - تعرض أصناف مصنّفة مع + / -
/// - تأخذ selectedItems من الصفحة الرئيسية (OrderPage)
/// - تستلم cityMultiplier لتعديل الأسعار حسب البلدية/المنطقة
class HomeCleaningServiceSection extends StatelessWidget {
  final Map<String, int> selectedItems;
  final void Function(String) onAddItem;
  final void Function(String) onRemoveItem;
  final double cityMultiplier;

  const HomeCleaningServiceSection({
    super.key,
    required this.selectedItems,
    required this.onAddItem,
    required this.onRemoveItem,
    required this.cityMultiplier,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _homeCleaningProducts.entries.map((entry) {
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
              final unit = product['unit'] as String; // قطعة/م²/م/طقم...
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
