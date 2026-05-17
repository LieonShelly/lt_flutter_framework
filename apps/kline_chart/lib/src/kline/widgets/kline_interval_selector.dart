import 'package:flutter/material.dart';
import 'package:wallet_domain/wallet_domain.dart';

class IntervalSelector extends StatelessWidget {
  final KlineInterval selectedInterval;
  final ValueChanged<KlineInterval> onIntervalChanged;

  const IntervalSelector({
    super.key,
    required this.selectedInterval,
    required this.onIntervalChanged,
  });

  static const _intervals = [
    KlineInterval.m1,
    KlineInterval.m5,
    KlineInterval.m15,
    KlineInterval.h1,
    KlineInterval.h4,
    KlineInterval.d1,
  ];

  static const _labels = {
    KlineInterval.m1: '1m',
    KlineInterval.m5: '5m',
    KlineInterval.m15: '15m',
    KlineInterval.h1: '1h',
    KlineInterval.h4: '4h',
    KlineInterval.d1: '1D',
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: _intervals.map((interval) {
          final isSelected = interval == selectedInterval;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ChoiceChip(
              label: Text(
                _labels[interval] ?? interval.apiValue,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              selected: isSelected,
              onSelected: (_) => onIntervalChanged(interval),
              selectedColor: Theme.of(context).colorScheme.primary,
              labelStyle: TextStyle(
                color: isSelected
                    ? Theme.of(context).colorScheme.onPrimary
                    : Theme.of(context).colorScheme.onSurface,
              ),
            ),
          );
        }).toList(),
        ),
      ),
    );
  }
}
