import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter_application_rpl_final/screens/dashboardscreen.dart';
import 'package:fl_chart/fl_chart.dart';

class StatisticsScreen extends StatefulWidget {
  final List<WeightEntry> weightEntries;

  const StatisticsScreen({
    super.key,
    required this.weightEntries,
  });

  @override
  State<StatisticsScreen> createState() => StatisticsScreenState();
}

class StatisticsScreenState extends State<StatisticsScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void didUpdateWidget(covariant StatisticsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.weightEntries != oldWidget.weightEntries) {
      print('StatisticsScreen: weightEntries updated! New length: ${widget.weightEntries.length}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color darkGreenBg = const Color(0xFF1D362C);
    final Color lightGreenText = const Color(0xFFA2F46E);
    final Color darkText = const Color(0xFF112D21);

    List<FlSpot> spots = [];
    List<WeightEntry> sortedEntries = [];

    if (widget.weightEntries.isNotEmpty) {
      sortedEntries = List.from(widget.weightEntries);
      sortedEntries.sort((a, b) => a.date.compareTo(b.date));

      for (int i = 0; i < sortedEntries.length; i++) {
        spots.add(FlSpot(i.toDouble(), sortedEntries[i].weight));
      }
    }

    double minWeight = widget.weightEntries.isNotEmpty ? widget.weightEntries.map((e) => e.weight).reduce((a, b) => a < b ? a : b) - 5 : 0;
    double maxWeight = widget.weightEntries.isNotEmpty ? widget.weightEntries.map((e) => e.weight).reduce((a, b) => a > b ? a : b) + 5 : 100;

    return Scaffold(
      backgroundColor: darkGreenBg,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.weightEntries.isEmpty)
              Center(
                child: Text(
                  'Belum ada data berat badan yang dicatat.',
                  style: TextStyle(fontSize: 18, color: lightGreenText.withOpacity(0.7)),
                  textAlign: TextAlign.center,
                ),
              )
            else ...[
              const SizedBox(height: 20),
              AspectRatio(
                aspectRatio: 1.7,
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: true,
                      horizontalInterval: 5, // Interval grid horizontal
                      verticalInterval: 1, // Interval grid vertical
                      getDrawingHorizontalLine: (value) {
                        return const FlLine(
                          color: Color(0xFF2E4E42), // Warna grid horizontal
                          strokeWidth: 1,
                        );
                      },
                      getDrawingVerticalLine: (value) {
                        return const FlLine(
                          color: Color(0xFF2E4E42), // Warna grid vertical
                          strokeWidth: 1,
                        );
                      },
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          getTitlesWidget: (value, TitleMeta meta) {
                            if (value.toInt() < widget.weightEntries.length) {
                              final entry = sortedEntries[value.toInt()];
                              return SideTitleWidget(
                                axisSide: meta.axisSide,
                                space: 8.0,
                                child: Text(
                                  '${entry.date.day}/${entry.date.month}',
                                  style: TextStyle(color: lightGreenText, fontSize: 10),
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          getTitlesWidget: (value, TitleMeta meta) {
                            return SideTitleWidget(
                              axisSide: meta.axisSide,
                              space: 8.0,
                              child: Text(
                                value.toInt().toString(),
                                style: TextStyle(color: lightGreenText, fontSize: 10),
                              ),
                            );
                          },
                          interval: 5,
                        ),
                      ),
                    ),
                    borderData: FlBorderData(
                      show: true,
                      border: Border.all(color: lightGreenText.withOpacity(0.5), width: 1),
                    ),
                    minX: 0,
                    maxX: spots.length <= 1 ? 1.0 : (spots.length - 1).toDouble(),
                    minY: minWeight,
                    maxY: maxWeight,
                    lineBarsData: [
                      LineChartBarData(
                        spots: spots,
                        isCurved: true,
                        color: lightGreenText, // Warna garis grafik
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: const FlDotData(show: true), // Tampilkan titik data
                        belowBarData: BarAreaData(
                          show: true,
                          color: lightGreenText.withOpacity(0.3),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Text(
                'Riwayat Berat Badan',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: lightGreenText),
              ),
              const SizedBox(height: 10),
              // Menampilkan daftar berat badan secara tradisional juga (opsional)
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(), // Menonaktifkan scroll ListView
                itemCount: widget.weightEntries.length,
                itemBuilder: (context, index) {
                  final entry = widget.weightEntries[index];
                  return Card(
                    color: darkGreenBg, 
                    elevation: 0,
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(color: lightGreenText.withOpacity(0.5), width: 1),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${entry.date.day.toString().padLeft(2, '0')}-${entry.date.month.toString().padLeft(2, '0')}-${entry.date.year}',
                            style: TextStyle(fontSize: 16, color: lightGreenText.withOpacity(0.8)),
                          ),
                          Text(
                            '${entry.weight.toStringAsFixed(1)} kg',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: lightGreenText),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
} 