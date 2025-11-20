import 'package:flutter/material.dart';
import 'package:flutter_application_rpl_final/screens/overviewresultscreen.dart'; // Akan dibuat selanjutnya
import 'dart:async'; // Import untuk Timer

class LoadingScreen extends StatefulWidget {
  final String name;
  final String gender;
  final int birthDay;
  final int birthMonth;
  final int birthYear;
  final double height;
  final double weight;
  final String activityLevel;
  final String goal;
  final String? email;
  final String? password;

  const LoadingScreen({
    super.key,
    required this.name,
    required this.gender,
    required this.birthDay,
    required this.birthMonth,
    required this.birthYear,
    required this.height,
    required this.weight,
    required this.activityLevel,
    required this.goal,
    this.email,
    this.password,
  });

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _startLoading();
  }

  void _startLoading() {
    const totalDuration = Duration(seconds: 3);
    const updateInterval = Duration(milliseconds: 50);
    int steps = totalDuration.inMilliseconds ~/ updateInterval.inMilliseconds;
    int currentStep = 0;

    Timer.periodic(updateInterval, (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        currentStep++;
        _progress = currentStep / steps; 
        if (_progress >= 1.0) {
          _progress = 1.0; // Ensure it doesn't exceed 1.0
          timer.cancel();
          _navigateToOverview();
        }
      });
    });
  }

  Future<void> _navigateToOverview() async {
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => OverviewResultScreen(
          name: widget.name,
          gender: widget.gender,
          birthDay: widget.birthDay,
          birthMonth: widget.birthMonth,
          birthYear: widget.birthYear,
          height: widget.height,
          weight: widget.weight,
          activityLevel: widget.activityLevel,
          goal: widget.goal,
          email: widget.email ?? '',
          password: widget.password ?? '',
        ),
      ),
      (Route<dynamic> route) => false, // Ini akan menghapus semua rute sebelumnya
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color darkGreenBg = const Color(0xFF1D362C);
    final Color lightGreenText = const Color(0xFFA2F46E);

    return Scaffold(
      backgroundColor: darkGreenBg, // Warna latar belakang sesuai desain
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              value: _progress, // Gunakan nilai progres
              valueColor: AlwaysStoppedAnimation<Color>(lightGreenText), // Warna loading
            ),
            const SizedBox(height: 20),
            Text(
              'Menghitung Hasil Anda...', 
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: lightGreenText,
              ),
            ),
            const SizedBox(height: 10), // Spasi antara teks dan persentase
            Text(
              '${(_progress * 100).toInt()}%',
              style: TextStyle(
                fontSize: 18,
                color: lightGreenText.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 