import 'package:flutter/material.dart';

/// نوع خدمة مدبرة منزل
enum MaidType { daily, liveIn }

/// واجهة مدبرة منزل(تعرض بطاقة واحدة فقط حسب الاختيار)
class MaidsServiceSection extends StatelessWidget {
  // الحالة (يأتي بها من OrderPage)
  final MaidType maidType;
  final int maidsCount; // عدد مدبرة منزل
  final int maidDays;   // الأيام (لـ daily) أو الأشهر (لـ liveIn)

  // ردود الأفعال
  final ValueChanged<MaidType> onMaidTypeChanged;
  final ValueChanged<int> onMaidsCountChanged;
  final ValueChanged<int> onMaidDaysChanged;

  // معامل المدينة لعرض الأسعار بعد الضرب
  final double cityMultiplier;

  // أسعار أساسية (نفس التعريفات في OrderPage)
  static const int _maidDailyPrice = 120;     // د.ل/مدبرة/يوم
  static const int _maidLiveInMonthly = 1800; // د.ل/مدبرة/شهر

  const MaidsServiceSection({
    super.key,
    required this.maidType,
    required this.maidsCount,
    required this.maidDays,
    required this.onMaidTypeChanged,
    required this.onMaidsCountChanged,
    required this.onMaidDaysChanged,
    required this.cityMultiplier,
  });

  int get _dayUnitPrice => (_maidDailyPrice * cityMultiplier).round();
  int get _liveInMonthlyPrice => (_maidLiveInMonthly * cityMultiplier).round();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // شريط اختيار النوع
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Radio<MaidType>(
                        value: MaidType.daily,
                        groupValue: maidType,
                        onChanged: (v) { if (v != null) onMaidTypeChanged(v); },
                      ),
                      const SizedBox(width: 4),
                      const Text('مدبرة منزل يومية'),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      Radio<MaidType>(
                        value: MaidType.liveIn,
                        groupValue: maidType,
                        onChanged: (v) { if (v != null) onMaidTypeChanged(v); },
                      ),
                      const SizedBox(width: 4),
                      const Text('مدبرة منزل مقيمة'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 10),

        // نعرض بطاقة واحدة فقط حسب الاختيار مع انتقال ناعم
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          transitionBuilder: (child, anim) =>
              FadeTransition(opacity: anim, child: child),
          child: maidType == MaidType.daily
              ? _DailyCard(
                  key: const ValueKey('dailyCard'),
                  title: 'مدبرة منزل يومية',
                  unitPriceLabel: '$_dayUnitPrice د.ل / مدبرة / يوم',
                  maidsCount: maidsCount,
                  daysOrMonths: maidDays,
                  onMaidsCountChanged: onMaidsCountChanged,
                  onDaysOrMonthsChanged: onMaidDaysChanged,
                )
              : _LiveInCard(
                  key: const ValueKey('liveInCard'),
                  title: 'مدبرة منزل مقيمة',
                  unitPriceLabel: '$_liveInMonthlyPrice د.ل / مدبرة / شهر',
                  maidsCount: maidsCount,
                  months: maidDays, // يعامل كأشهر
                  onMaidsCountChanged: onMaidsCountChanged,
                  onMonthsChanged: onMaidDaysChanged,
                ),
        ),
      ],
    );
  }
}

/// بطاقة عمالة يومية
class _DailyCard extends StatelessWidget {
  final String title;
  final String unitPriceLabel;
  final int maidsCount;
  final int daysOrMonths;
  final ValueChanged<int> onMaidsCountChanged;
  final ValueChanged<int> onDaysOrMonthsChanged;

  const _DailyCard({
    super.key,
    required this.title,
    required this.unitPriceLabel,
    required this.maidsCount,
    required this.daysOrMonths,
    required this.onMaidsCountChanged,
    required this.onDaysOrMonthsChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.cleaning_services),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                Text(unitPriceLabel, style: TextStyle(fontSize: 13, color: Colors.grey.shade700)),
              ],
            ),
            const SizedBox(height: 12),
            _CounterLine(
              title: 'عدد مدبرة منزل',
              count: maidsCount,
              onDec: () => onMaidsCountChanged(maidsCount > 1 ? maidsCount - 1 : 1),
              onInc: () => onMaidsCountChanged(maidsCount + 1),
            ),
            const SizedBox(height: 8),
            _CounterLine(
              title: 'عدد الأيام',
              count: daysOrMonths,
              onDec: () => onDaysOrMonthsChanged(daysOrMonths > 1 ? daysOrMonths - 1 : 1),
              onInc: () => onDaysOrMonthsChanged(daysOrMonths + 1),
            ),
          ],
        ),
      ),
    );
  }
}

/// بطاقة مدبرة منزل مقيمة
class _LiveInCard extends StatelessWidget {
  final String title;
  final String unitPriceLabel;
  final int maidsCount;
  final int months;
  final ValueChanged<int> onMaidsCountChanged;
  final ValueChanged<int> onMonthsChanged;

  const _LiveInCard({
    super.key,
    required this.title,
    required this.unitPriceLabel,
    required this.maidsCount,
    required this.months,
    required this.onMaidsCountChanged,
    required this.onMonthsChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.home),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                Text(unitPriceLabel, style: TextStyle(fontSize: 13, color: Colors.grey.shade700)),
              ],
            ),
            const SizedBox(height: 12),
            _CounterLine(
              title: 'عدد مدبرة منزل',
              count: maidsCount,
              onDec: () => onMaidsCountChanged(maidsCount > 1 ? maidsCount - 1 : 1),
              onInc: () => onMaidsCountChanged(maidsCount + 1),
            ),
            const SizedBox(height: 8),
            _CounterLine(
              title: 'عدد الأشهر',
              count: months,
              onDec: () => onMonthsChanged(months > 1 ? months - 1 : 1),
              onInc: () => onMonthsChanged(months + 1),
            ),
          ],
        ),
      ),
    );
  }
}

class _CounterLine extends StatelessWidget {
  final String title;
  final int count;
  final VoidCallback onDec;
  final VoidCallback onInc;

  const _CounterLine({
    required this.title,
    required this.count,
    required this.onDec,
    required this.onInc,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(title, style: const TextStyle(fontSize: 15))),
        IconButton(onPressed: onDec, icon: const Icon(Icons.remove_circle_outline, color: Colors.red)),
        Text('$count', style: const TextStyle(fontSize: 16)),
        IconButton(onPressed: onInc, icon: const Icon(Icons.add_circle_outline, color: Colors.green)),
      ],
    );
  }
}
