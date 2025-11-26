import 'package:flutter/material.dart';
import 'package:flutter_application_rpl_final/screens/dashboardscreen.dart';
import 'package:flutter_application_rpl_final/screens/addweightscreen.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter_application_rpl_final/widgets/sound_helper.dart';

class StatisticsScreen extends StatefulWidget {
  final List<WeightEntry> weightEntries;

  const StatisticsScreen({super.key, required this.weightEntries});

  @override
  State<StatisticsScreen> createState() => StatisticsScreenState();
}

class StatisticsScreenState extends State<StatisticsScreen> {
  late List<WeightEntry> _entries;

  @override
  void initState() {
    super.initState();
    _entries = List.from(widget.weightEntries);
  }

  @override
  void didUpdateWidget(covariant StatisticsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.weightEntries != oldWidget.weightEntries) {
      print(
        'StatisticsScreen: weightEntries updated! New length: ${widget.weightEntries.length}',
      );
      setState(() {
        _entries = List.from(widget.weightEntries);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color darkGreenBg = const Color(0xFF1D362C);
    final Color lightGreenText = const Color(0xFFA2F46E);

    List<FlSpot> spots = [];
    List<WeightEntry> sortedEntries = [];

    if (_entries.isNotEmpty) {
      sortedEntries = List.from(_entries);
      sortedEntries.sort((a, b) => a.date.compareTo(b.date));

      for (int i = 0; i < sortedEntries.length; i++) {
        spots.add(FlSpot(i.toDouble(), sortedEntries[i].weight));
      }
    }

    double minWeight = _entries.isNotEmpty
        ? _entries.map((e) => e.weight).reduce((a, b) => a < b ? a : b) - 5
        : 0;
    double maxWeight = _entries.isNotEmpty
        ? _entries.map((e) => e.weight).reduce((a, b) => a > b ? a : b) + 5
        : 100;

    return Scaffold(
      backgroundColor: darkGreenBg,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_entries.isEmpty)
              Center(
                child: Text(
                  'Belum ada data berat badan yang dicatat.',
                  style: TextStyle(
                    fontSize: 18,
                    color: lightGreenText.withOpacity(0.7),
                  ),
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
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
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
                                  style: TextStyle(
                                    color: lightGreenText,
                                    fontSize: 10,
                                  ),
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
                                style: TextStyle(
                                  color: lightGreenText,
                                  fontSize: 10,
                                ),
                              ),
                            );
                          },
                          interval: 5,
                        ),
                      ),
                    ),
                    borderData: FlBorderData(
                      show: true,
                      border: Border.all(
                        color: lightGreenText.withOpacity(0.5),
                        width: 1,
                      ),
                    ),
                    minX: 0,
                    maxX: spots.length <= 1
                        ? 1.0
                        : (spots.length - 1).toDouble(),
                    minY: minWeight,
                    maxY: maxWeight,
                    lineBarsData: [
                      LineChartBarData(
                        spots: spots,
                        isCurved: true,
                        color: lightGreenText, // Warna garis grafik
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: const FlDotData(
                          show: true,
                        ), // Tampilkan titik data
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Riwayat Berat Badan',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: lightGreenText,
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      await SoundHelper.playTransition();
                      if (!mounted) return;
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddWeightScreen(
                            onWeightAdded: (weight) {
                              _addWeight(weight);
                            },
                          ),
                        ),
                      );
                      // Refresh data setelah kembali dari AddWeightScreen
                      if (mounted) {
                        await _loadWeightEntries();
                      }
                    },
                    icon: Icon(
                      Icons.add_circle_outline,
                      color: lightGreenText,
                      size: 32,
                    ),
                    tooltip: 'Catat Berat Badan',
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Menampilkan daftar berat badan secara tradisional juga (opsional)
              ListView.builder(
                shrinkWrap: true,
                physics:
                    const NeverScrollableScrollPhysics(), // Menonaktifkan scroll ListView
                itemCount: _entries.length,
                itemBuilder: (context, index) {
                  final entry = _entries[index];
                  return Card(
                    color: darkGreenBg,
                    elevation: 0,
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                        color: lightGreenText.withOpacity(0.5),
                        width: 1,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${entry.date.day.toString().padLeft(2, '0')}-${entry.date.month.toString().padLeft(2, '0')}-${entry.date.year}',
                            style: TextStyle(
                              fontSize: 16,
                              color: lightGreenText.withOpacity(0.8),
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                '${entry.weight.toStringAsFixed(1)} kg',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: lightGreenText,
                                ),
                              ),
                              IconButton(
                                onPressed: () => _showEditWeightDialog(index),
                                icon: Icon(Icons.edit, color: lightGreenText),
                              ),
                            ],
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

  Future<void> _showEditWeightDialog(int index) async {
    final entry = _entries[index];
    final controller = TextEditingController(
      text: entry.weight.toStringAsFixed(1),
    );

    final result = await showDialog<double>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1D362C),
          title: const Text(
            'Ubah Berat Badan',
            style: TextStyle(color: Color(0xFFA2F46E)),
          ),
          content: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(color: Color(0xFFA2F46E)),
            decoration: const InputDecoration(
              labelText: 'Berat (kg)',
              labelStyle: TextStyle(color: Color(0xFFA2F46E)),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFA2F46E)),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFA2F46E)),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await SoundHelper.playTransition();
                if (mounted) {
                  Navigator.pop(context);
                }
              },
              child: const Text(
                'Batal',
                style: TextStyle(color: Color(0xFFA2F46E)),
              ),
            ),
            TextButton(
              onPressed: () async {
                final newWeight = double.tryParse(controller.text);
                if (newWeight != null && newWeight > 0) {
                  await SoundHelper.playTransition();
                  if (mounted) {
                    Navigator.pop(context, newWeight);
                  }
                }
              },
              child: const Text(
                'Simpan',
                style: TextStyle(color: Color(0xFFA2F46E)),
              ),
            ),
          ],
        );
      },
    );

    if (result != null) {
      setState(() {
        _entries[index] = WeightEntry(weight: result, date: entry.date);
      });
      await _persistWeightEntries();
    }
  }

  Future<void> _addWeight(double weight) async {
    final newEntry = WeightEntry(weight: weight, date: DateTime.now());

    // Tambahkan ke entries dan simpan
    setState(() {
      _entries.add(newEntry);
      // Urutkan berdasarkan tanggal (terbaru di atas)
      _entries.sort((a, b) => b.date.compareTo(a.date));
    });

    await _persistWeightEntries();

    // Refresh data dari SharedPreferences untuk memastikan sinkronisasi
    if (mounted) {
      await _loadWeightEntries();
    }
  }

  Future<void> _loadWeightEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? weightEntriesJson = prefs.getStringList(
      'all_weight_entries',
    );

    if (weightEntriesJson != null) {
      setState(() {
        _entries = weightEntriesJson
            .map((entryJson) => WeightEntry.fromJson(jsonDecode(entryJson)))
            .toList();
        _entries.sort((a, b) => b.date.compareTo(a.date));
      });
    }
  }

  Future<void> _persistWeightEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> entriesJson = _entries
        .map((entry) => jsonEncode(entry.toJson()))
        .toList();
    await prefs.setStringList('all_weight_entries', entriesJson);

    // Update profil user dengan berat badan terbaru
    if (_entries.isNotEmpty) {
      // Urutkan berdasarkan tanggal (terbaru di atas)
      final List<WeightEntry> sorted = List.from(_entries)
        ..sort((a, b) => b.date.compareTo(a.date));
      final double latestWeight = sorted.first.weight;

      final String? profileJson = prefs.getString('user_profile_data');
      if (profileJson != null) {
        final Map<String, dynamic> profileData = jsonDecode(profileJson);
        profileData['weight'] = latestWeight; // Update berat badan di profil
        await prefs.setString('user_profile_data', jsonEncode(profileData));
        print('User profile weight updated to: $latestWeight kg');
      }
    }
  }
}
