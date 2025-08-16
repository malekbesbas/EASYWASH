import 'package:flutter/material.dart';

class CarwashServiceSection extends StatelessWidget {
  final String carType; // 
  final int carsCount;
  final int unitPrice; // السعر بعد معامل المدينة
  final ValueChanged<String> onCarTypeChanged;
  final ValueChanged<int> onCarsCountChanged;

  const CarwashServiceSection({
    Key? key,
    required this.carType,
    required this.carsCount,
    required this.unitPrice,
    required this.onCarTypeChanged,
    required this.onCarsCountChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final types = const ['Sedan', 'SUV', 'Van'];

    return Card(
      color: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.local_car_wash, color: Colors.blue.shade700),
                const SizedBox(width: 8),
                Text('غسيل السيارات', style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue.shade800,
                )),
              ],
            ),
            const SizedBox(height: 14),

            // اختيار نوع السيارة
            DropdownButtonFormField<String>(
              isExpanded: true,
              value: carType,
              items: types.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
              onChanged: (v) { if (v != null) onCarTypeChanged(v); },
              decoration: InputDecoration(
                labelText: 'نوع السيارة',
                filled: true,
                fillColor: Colors.grey.shade50,
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
            ),

            const SizedBox(height: 12),

            // سعر الوحدة (بعد معامل المدينة)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('السعر لكل سيارة'),
                Text('$unitPrice د.ل', style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),

            const SizedBox(height: 12),

            // عدد السيارات
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('عدد السيارات'),
                Row(
                  children: [
                    IconButton(
                      onPressed: carsCount > 0 ? () => onCarsCountChanged(carsCount - 1) : null,
                      icon: const Icon(Icons.remove_circle_outline),
                    ),
                    Text('$carsCount', style: const TextStyle(fontSize: 16)),
                    IconButton(
                      onPressed: () => onCarsCountChanged(carsCount + 1),
                      icon: const Icon(Icons.add_circle_outline),
                    ),
                  ],
                ),
              ],
            ),

            const Divider(height: 24),
          ],
        ),
      ),
    );
  }
}
