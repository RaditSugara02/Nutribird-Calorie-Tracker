import 'package:flutter/material.dart';
import 'package:flutter_application_rpl_final/screens/inputgoalscreen.dart';
import 'package:flutter_application_rpl_final/widgets/progress_bar.dart';
import 'package:flutter_application_rpl_final/widgets/sound_helper.dart';
import 'package:flutter_application_rpl_final/widgets/custom_page_route.dart';

class InputActivityLevelScreen extends StatefulWidget {
  final String name;
  final String gender;
  final int birthDay;
  final int birthMonth;
  final int birthYear;
  final double height;
  final double weight;

  const InputActivityLevelScreen({
    super.key,
    required this.name,
    required this.gender,
    required this.birthDay,
    required this.birthMonth,
    required this.birthYear,
    required this.height,
    required this.weight,
  });

  @override
  State<InputActivityLevelScreen> createState() =>
      _InputActivityLevelScreenState();
}

class _InputActivityLevelScreenState extends State<InputActivityLevelScreen> {
  String? _selectedActivityLevel;

  final List<Map<String, String>> _activityLevels = [
    {
      'level': 'Sangat Sedentari',
      'description': 'Sedikit atau tanpa olahraga.',
    },
    {
      'level': 'Ringan Aktif',
      'description': 'Olahraga ringan 1-3 hari/minggu.',
    },
    {'level': 'Cukup Aktif', 'description': 'Olahraga sedang 3-5 hari/minggu.'},
    {'level': 'Sangat Aktif', 'description': 'Olahraga berat 6-7 hari/minggu.'},
    {
      'level': 'Ekstra Aktif',
      'description': 'Olahraga sangat berat & pekerjaan fisik.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final Color darkGreenBg = const Color(0xFF1D362C);
    final Color lightGreenText = const Color(0xFFA2F46E);
    final Color darkText = const Color(0xFF112D21);

    return Scaffold(
      backgroundColor: darkGreenBg,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back_ios, color: lightGreenText),
                  onPressed: () async {
                    if (mounted) {
                      Navigator.pop(context);
                    }
                  },
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      right: 20.0,
                    ), // Adjust padding as needed
                    child: ProgressBar(currentStep: 6, totalSteps: 7),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'Bagaimana tingkat aktivitas harian Anda?',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: lightGreenText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Pilih tingkat aktivitas Anda untuk perhitungan kalori yang lebih akurat.',
              style: TextStyle(
                fontSize: 16,
                color: lightGreenText.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 40),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _activityLevels.length,
              itemBuilder: (context, index) {
                final level = _activityLevels[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 15.0),
                  child: _buildActivityLevelOption(
                    context,
                    level['level']!,
                    level['description']!,
                  ),
                );
              },
            ),
            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  if (_selectedActivityLevel == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Mohon pilih tingkat aktivitas Anda'),
                      ),
                    );
                  } else {
                    if (mounted) {
                      Navigator.push(
                        context,
                        CustomPageRoute(
                          child: InputGoalScreen(
                            name: widget.name,
                            gender: widget.gender,
                            birthDay: widget.birthDay,
                            birthMonth: widget.birthMonth,
                            birthYear: widget.birthYear,
                            height: widget.height,
                            weight: widget.weight,
                            activityLevel: _selectedActivityLevel!,
                          ),
                          backgroundColor: const Color(0xFF1D362C),
                        ),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: lightGreenText,
                  foregroundColor: darkText,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Lanjutkan',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityLevelOption(
    BuildContext context,
    String level,
    String description,
  ) {
    final Color darkGreenBg = const Color(0xFF1D362C);
    final Color lightGreenText = const Color(0xFFA2F46E);
    final Color darkText = const Color(0xFF112D21);

    bool isSelected = _selectedActivityLevel == level;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedActivityLevel = level;
        });
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? lightGreenText : darkGreenBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? Colors.transparent : lightGreenText,
            width: 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              level,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isSelected ? darkText : lightGreenText,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              description,
              style: TextStyle(
                fontSize: 14,
                color: isSelected
                    ? darkText.withOpacity(0.8)
                    : lightGreenText.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
