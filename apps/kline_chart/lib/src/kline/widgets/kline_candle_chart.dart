import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:wallet_domain/wallet_domain.dart';

class KlineCandleChart extends StatefulWidget {
  final List<CandleEntity> candles;
  final ScrollController? scrollController;

  const KlineCandleChart({
    super.key,
    required this.candles,
    this.scrollController,
  });

  @override
  State<KlineCandleChart> createState() => _KlineCandleChartState();
}

class _KlineCandleChartState extends State<KlineCandleChart> {
  double _minY = 0;
  double _maxY = 0;
  double _minX = 0;
  double _maxX = 0;

  @override
  void initState() {
    super.initState();
    _calculateBounds();
  }

  @override
  void didUpdateWidget(KlineCandleChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.candles != widget.candles) {
      _calculateBounds();
    }
  }

  void _calculateBounds() {
    if (widget.candles.isEmpty) return;

    double minLow = double.infinity;
    double maxHigh = double.negativeInfinity;

    for (final candle in widget.candles) {
      if (candle.low < minLow) minLow = candle.low;
      if (candle.high > maxHigh) maxHigh = candle.high;
    }

    final padding = (maxHigh - minLow) * 0.1;
    _minY = minLow - padding;
    _maxY = maxHigh + padding;
    _minX = 0;
    _maxX = (widget.candles.length - 1).toDouble();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.candles.isEmpty) {
      return const Center(child: Text('暂无数据'));
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: LineChart(
        LineChartData(
          minX: _minX,
          maxX: _maxX,
          minY: _minY,
          maxY: _maxY,
          clipData: const FlClipData.all(),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 60,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toStringAsFixed(2),
                    style: const TextStyle(fontSize: 10),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: (_maxX - _minX) / 6,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= widget.candles.length) {
                    return const SizedBox.shrink();
                  }
                  final candle = widget.candles[index];
                  final date = DateTime.fromMillisecondsSinceEpoch(candle.openTime);
                  return Text(
                    '${date.month}/${date.day}',
                    style: const TextStyle(fontSize: 10),
                  );
                },
              ),
            ),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: true,
            horizontalInterval: (_maxY - _minY) / 5,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.grey.withValues(alpha: 0.2),
                strokeWidth: 1,
              );
            },
            getDrawingVerticalLine: (value) {
              return FlLine(
                color: Colors.grey.withValues(alpha: 0.2),
                strokeWidth: 1,
              );
            },
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
          ),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((spot) {
                  final index = spot.x.toInt();
                  if (index < 0 || index >= widget.candles.length) {
                    return null;
                  }
                  final candle = widget.candles[index];
                  return LineTooltipItem(
                    'O: ${candle.open.toStringAsFixed(2)}\n'
                    'H: ${candle.high.toStringAsFixed(2)}\n'
                    'L: ${candle.low.toStringAsFixed(2)}\n'
                    'C: ${candle.close.toStringAsFixed(2)}',
                    const TextStyle(color: Colors.white, fontSize: 12),
                  );
                }).toList();
              },
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: widget.candles.asMap().entries.map((entry) {
                return FlSpot(entry.key.toDouble(), entry.value.close);
              }).toList(),
              isCurved: false,
              color: Colors.blue,
              barWidth: 1,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: Colors.blue.withValues(alpha: 0.1),
              ),
            ),
          ],
        ),
        duration: const Duration(milliseconds: 250),
      ),
    );
  }
}
