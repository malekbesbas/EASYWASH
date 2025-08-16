import 'package:flutter/material.dart';

/// واجهة خدمة السجاد: عداد فقط، السعر/قطعة يُمرَّر من الصفحة
class CarpetServiceSection extends StatelessWidget {
  final int count;
  final int pricePerPiece;
  final VoidCallback onInc;
  final VoidCallback onDec;

  const CarpetServiceSection({
    super.key,
    required this.count,
    required this.pricePerPiece,
    required this.onInc,
    required this.onDec,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('عدد قطع السجاد ($pricePerPiece د.ل/قطعة)', style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(onPressed: onDec, icon: const Icon(Icons.remove_circle)),
            Text('$count قطعة', style: const TextStyle(fontSize: 16)),
            IconButton(onPressed: onInc, icon: const Icon(Icons.add_circle)),
          ],
        ),
      ],
    );
  }
}
