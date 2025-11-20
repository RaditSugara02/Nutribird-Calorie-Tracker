import 'package:flutter/material.dart';
import 'package:flutter_application_rpl_final/screens/loadingscreen.dart';
import 'package:flutter_application_rpl_final/widgets/progress_bar.dart';

class InputGoalScreen extends StatefulWidget {
  final String name;
  final String gender;
  final int birthDay;
  final int birthMonth;
  final int birthYear;
  final double height;
  final double weight;
  final String activityLevel;
  final String? email;
  final String? password;

  const InputGoalScreen({
    super.key,
    required this.name,
    required this.gender,
    required this.birthDay,
    required this.birthMonth,
    required this.birthYear,
    required this.height,
    required this.weight,
    required this.activityLevel,
    this.email,
    this.password,
  });

  @override
  State<InputGoalScreen> createState() => _InputGoalScreenState();
}

class _InputGoalScreenState extends State<InputGoalScreen> {
  String? _selectedGoal;

  final List<String> _goals = [
    'Menjaga Berat Badan',
    'Menurunkan Berat Badan Ringan (0.25 kg/minggu)',
    'Menurunkan Berat Badan Sedang (0.5 kg/minggu)',
    'Menurunkan Berat Badan Ekstrim (1 kg/minggu)',
    'Menambah Berat Badan',
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
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 20.0), // Adjust padding as needed
                    child: ProgressBar(currentStep: 7, totalSteps: 7),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'Apa tujuan utama Anda?',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: lightGreenText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Pilih tujuan utama Anda untuk personalisasi rekomendasi kalori.',
              style: TextStyle(
                fontSize: 16,
                color: lightGreenText.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 40),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _goals.length,
              itemBuilder: (context, index) {
                final goal = _goals[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 15.0),
                  child: _buildGoalOption(
                    context,
                    goal,
                  ),
                );
              },
            ),
            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (_selectedGoal == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Mohon pilih tujuan Anda')),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LoadingScreen(
                          name: widget.name,
                          gender: widget.gender,
                          birthDay: widget.birthDay,
                          birthMonth: widget.birthMonth,
                          birthYear: widget.birthYear,
                          height: widget.height,
                          weight: widget.weight,
                          activityLevel: widget.activityLevel,
                          goal: _selectedGoal!,
                          email: widget.email ?? '',
                          password: widget.password ?? '',
                        ),
                      ),
                    );
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

  Widget _buildGoalOption(BuildContext context, String goal) {
    final Color darkGreenBg = const Color(0xFF1D362C);
    final Color lightGreenText = const Color(0xFFA2F46E);
    final Color darkText = const Color(0xFF112D21);

    bool isSelected = _selectedGoal == goal;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedGoal = goal;
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                goal,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? darkText : lightGreenText,
                ),
              ),
            ),
            Icon(
              isSelected ? Icons.check_circle : Icons.circle_outlined,
              color: isSelected ? darkText : lightGreenText,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
} 