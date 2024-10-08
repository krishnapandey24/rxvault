import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../models/analytics_response.dart';

class AnalyticsBarChart extends StatefulWidget {
  final bool showAmount;
  final List<AnalyticsData> data;
  final double maxAmount;
  final double maxPatientCount;

  const AnalyticsBarChart({
    super.key,
    required this.data,
    required this.showAmount,
    required this.maxAmount,
    required this.maxPatientCount,
  });

  @override
  AnalyticsBarChartState createState() => AnalyticsBarChartState();
}

class AnalyticsBarChartState extends State<AnalyticsBarChart> {
  int touchedGroupIndex = -1;

  get showAmount => widget.showAmount;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: BarChart(
          BarChartData(
            minY: 0,
            maxY: getMaxY(),
            barGroups: widget.data.asMap().entries.map((entry) {
              int index = entry.key;
              AnalyticsData data = entry.value;
              return BarChartGroupData(
                x: index,
                barRods: [
                  BarChartRodData(
                    toY: showAmount
                        ? data.amount.toDouble()
                        : data.count.toDouble(),
                    borderRadius: BorderRadius.zero,
                  ),
                ],
              );
            }).toList(),
            titlesData: FlTitlesData(
              topTitles: const AxisTitles(
                sideTitles: SideTitles(
                  showTitles: false,
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (double value, TitleMeta meta) {
                    return Text(
                      meta.formattedValue,
                      style: const TextStyle(fontSize: 8),
                    );
                  },
                ),
              ),
              rightTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (double value, TitleMeta meta) {
                    return SideTitleWidget(
                      axisSide: meta.axisSide,
                      child: Text(
                        meta.formattedValue,
                        style: const TextStyle(fontSize: 8),
                      ),
                    );
                  },
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (double value, TitleMeta meta) {
                    int index = value.toInt();
                    if (index < 0 || index >= widget.data.length) {
                      return const Text('');
                    }
                    return Text(
                      "${index + 1}",
                      style: const TextStyle(fontSize: 8),
                    );
                  },
                ),
              ),
            ),
            borderData: FlBorderData(show: true),
            gridData: const FlGridData(show: true),
          ),
        ),
      ),
    );
  }

  double determineMax() {
    if (showAmount) {
      return widget.data
              .map((data) => data.amount)
              .reduce((a, b) => a > b ? a : b) +
          100;
    } else {
      return widget.data
              .map((data) => data.count)
              .reduce((a, b) => a > b ? a : b) +
          10;
    }
  }

  double getMaxY() {
    double maxAmount = widget.maxAmount;
    double maxPatientCount = widget.maxPatientCount;
    int maxY;
    if (showAmount) {
      if (maxAmount == 0) return 10000.0;
      maxY = (widget.maxAmount + (widget.maxAmount * 0.2)).ceil();
    } else {
      if (maxPatientCount < 10) return 10.0;
      maxY = (widget.maxPatientCount + (widget.maxPatientCount * 0.2)).ceil();
    }

    return maxY.toDouble();
  }
}
