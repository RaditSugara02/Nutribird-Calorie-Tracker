import 'package:flutter/material.dart';
import 'package:flutter_application_rpl_final/screens/dashboardscreen.dart';
import 'package:flutter_application_rpl_final/screens/inputnamescreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter_application_rpl_final/widgets/sound_helper.dart';
import 'package:flutter_application_rpl_final/widgets/custom_page_route.dart';

class OverviewResultScreen extends StatelessWidget {
  final String name;
  final String gender;
  final int birthDay;
  final int birthMonth;
  final int birthYear;
  final double height;
  final double weight;
  final String activityLevel;
  final String goal;

  const OverviewResultScreen({
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
  });

  // Method untuk menyimpan data profil pengguna
  Future<void> _saveUserProfile() async {
    final prefs = await SharedPreferences.getInstance();

    final int currentYear = DateTime.now().year;
    final int age = currentYear - birthYear;

    // Calculate BMR (Mifflin-St Jeor Equation)
    double bmr;
    if (gender == 'Laki-laki') {
      bmr = (10 * weight) + (6.25 * height) - (5 * age) + 5;
    } else {
      bmr = (10 * weight) + (6.25 * height) - (5 * age) - 161;
    }

    // Calculate TDEE based on activity level
    double activityFactor;
    switch (activityLevel) {
      case 'Sangat Sedentari':
        activityFactor = 1.2;
        break;
      case 'Ringan Aktif':
        activityFactor = 1.375;
        break;
      case 'Cukup Aktif':
        activityFactor = 1.55;
        break;
      case 'Sangat Aktif':
        activityFactor = 1.725;
        break;
      case 'Ekstra Aktif':
        activityFactor = 1.9;
        break;
      default:
        activityFactor = 1.2; // Default to sedentary
    }
    double tdee = bmr * activityFactor;

    // Adjust calories based on goal
    double dailyCalories;
    switch (goal) {
      case 'Menjaga Berat Badan':
        dailyCalories = tdee;
        break;
      case 'Menurunkan Berat Badan Ringan (0.25 kg/minggu)':
        dailyCalories =
            tdee - 250; // Defisit 250 kalori per hari untuk ~0.25 kg/minggu
        break;
      case 'Menurunkan Berat Badan Sedang (0.5 kg/minggu)':
        dailyCalories =
            tdee - 500; // Defisit 500 kalori per hari untuk ~0.5 kg/minggu
        break;
      case 'Menurunkan Berat Badan Ekstrim (1 kg/minggu)':
        dailyCalories =
            tdee - 1000; // Defisit 1000 kalori per hari untuk ~1 kg/minggu
        break;
      case 'Menambah Berat Badan':
        dailyCalories = tdee + 500; // Surplus 500 kalori per hari
        break;
      default:
        dailyCalories = tdee;
    }

    // Ensure daily calories don't go below a healthy minimum (e.g., 1200 for women, 1500 for men, adjust as needed)
    if (gender == 'Perempuan' && dailyCalories < 1200) dailyCalories = 1200;
    if (gender == 'Laki-laki' && dailyCalories < 1500) dailyCalories = 1500;

    // Calculate BMI
    final double heightInMeters = height / 100;
    final double bmi = weight / (heightInMeters * heightInMeters);

    // Calculate macronutrients based on dailyCalories
    // Using common ratios: Protein 20%, Fat 30%, Carbs 50%
    // 1g Protein = 4 kcal, 1g Fat = 9 kcal, 1g Carbs = 4 kcal
    final double proteinGrams = (dailyCalories * 0.20) / 4;
    final double fatGrams = (dailyCalories * 0.30) / 9;
    final double carbGrams = (dailyCalories * 0.50) / 4;

    final Map<String, dynamic> userProfileData = {
      'name': name,
      'gender': gender,
      'birthDay': birthDay,
      'birthMonth': birthMonth,
      'birthYear': birthYear,
      'height': height,
      'weight': weight,
      'activityLevel': activityLevel,
      'goal': goal,
      'dailyCalories': dailyCalories.round(),
      'proteinGrams': proteinGrams.round(),
      'fatGrams': fatGrams.round(),
      'carbGrams': carbGrams.round(),
      'bmi': bmi.toStringAsFixed(1),
    };

    await prefs.setString('user_profile_data', jsonEncode(userProfileData));
    print('User Profile Saved: ${jsonEncode(userProfileData)}');

    await _ensureInitialWeightEntry(prefs);
  }

  Future<void> _ensureInitialWeightEntry(SharedPreferences prefs) async {
    final List<String>? existingEntriesJson = prefs.getStringList(
      'all_weight_entries',
    );
    final List<Map<String, dynamic>> existingEntries =
        existingEntriesJson
            ?.map((entry) => jsonDecode(entry) as Map<String, dynamic>)
            .toList() ??
        [];

    if (existingEntries.isEmpty) {
      final newEntry = {
        'weight': weight,
        'date': DateTime.now().toIso8601String(),
      };
      existingEntries.add(newEntry);
      await prefs.setStringList(
        'all_weight_entries',
        existingEntries.map((entry) => jsonEncode(entry)).toList(),
      );
      print('Initial weight entry added: $newEntry');
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color darkGreenBg = const Color(0xFF1D362C);
    final Color lightGreenText = const Color(0xFFA2F46E);
    final Color darkText = const Color(0xFF112D21);

    // Calculate age
    final int currentYear = DateTime.now().year;
    final int age = currentYear - birthYear;

    // Calculate BMR (Mifflin-St Jeor Equation)
    double bmr;
    if (gender == 'Laki-laki') {
      bmr = (10 * weight) + (6.25 * height) - (5 * age) + 5;
    } else {
      bmr = (10 * weight) + (6.25 * height) - (5 * age) - 161;
    }

    // Calculate TDEE based on activity level
    double activityFactor;
    switch (activityLevel) {
      case 'Sangat Sedentari':
        activityFactor = 1.2;
        break;
      case 'Ringan Aktif':
        activityFactor = 1.375;
        break;
      case 'Cukup Aktif':
        activityFactor = 1.55;
        break;
      case 'Sangat Aktif':
        activityFactor = 1.725;
        break;
      case 'Ekstra Aktif':
        activityFactor = 1.9;
        break;
      default:
        activityFactor = 1.2; // Default to sedentary
    }
    double tdee = bmr * activityFactor;

    // Adjust calories based on goal
    double dailyCalories;
    switch (goal) {
      case 'Menjaga Berat Badan':
        dailyCalories = tdee;
        break;
      case 'Menurunkan Berat Badan Ringan (0.25 kg/minggu)':
        dailyCalories =
            tdee - 250; // Defisit 250 kalori per hari untuk ~0.25 kg/minggu
        break;
      case 'Menurunkan Berat Badan Sedang (0.5 kg/minggu)':
        dailyCalories =
            tdee - 500; // Defisit 500 kalori per hari untuk ~0.5 kg/minggu
        break;
      case 'Menurunkan Berat Badan Ekstrim (1 kg/minggu)':
        dailyCalories =
            tdee - 1000; // Defisit 1000 kalori per hari untuk ~1 kg/minggu
        break;
      case 'Menambah Berat Badan':
        dailyCalories = tdee + 500; // Surplus 500 kalori per hari
        break;
      default:
        dailyCalories = tdee;
    }

    // Ensure daily calories don't go below a healthy minimum (e.g., 1200 for women, 1500 for men, adjust as needed)
    if (gender == 'Perempuan' && dailyCalories < 1200) dailyCalories = 1200;
    if (gender == 'Laki-laki' && dailyCalories < 1500) dailyCalories = 1500;

    // Calculate BMI
    final double heightInMeters = height / 100;
    final double bmi = weight / (heightInMeters * heightInMeters);

    // Calculate macronutrients based on dailyCalories
    // Using common ratios: Protein 20%, Fat 30%, Carbs 50%
    // 1g Protein = 4 kcal, 1g Fat = 9 kcal, 1g Carbs = 4 kcal
    final double proteinGrams = (dailyCalories * 0.20) / 4;
    final double fatGrams = (dailyCalories * 0.30) / 9;
    final double carbGrams = (dailyCalories * 0.50) / 4;

    // Call _saveUserProfile after calculations are done and before building the UI or navigating
    _saveUserProfile();

    return Scaffold(
      backgroundColor: darkGreenBg,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Text(
              'Selamat, ${name.split(' ').first}! ',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: lightGreenText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Rencana kalori pribadimu sudah siap!',
              style: TextStyle(fontSize: 24, color: lightGreenText),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text(
                      'Kebutuhan Kalori Kamu',
                      style: TextStyle(
                        fontSize: 16,
                        color: lightGreenText.withOpacity(0.8),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      dailyCalories.round().toString(),
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: lightGreenText,
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      'BMI',
                      style: TextStyle(
                        fontSize: 16,
                        color: lightGreenText.withOpacity(0.8),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      bmi.toStringAsFixed(1), // Show BMI with one decimal place
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: lightGreenText,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMacronutrientColumn(
                  'Karbo',
                  carbGrams.round(),
                  lightGreenText,
                  darkGreenBg,
                ),
                _buildMacronutrientColumn(
                  'Lemak',
                  fatGrams.round(),
                  lightGreenText,
                  darkGreenBg,
                ),
                _buildMacronutrientColumn(
                  'Protein',
                  proteinGrams.round(),
                  lightGreenText,
                  darkGreenBg,
                ),
              ],
            ),
            const SizedBox(height: 30),
            Card(
              color: darkGreenBg,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(color: lightGreenText, width: 2),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Detail Profil Anda',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: lightGreenText,
                      ),
                    ),
                    const SizedBox(height: 15),
                    _buildInfoRow('Nama', name, lightGreenText),
                    const SizedBox(height: 10),
                    _buildInfoRow('Gender', gender, lightGreenText),
                    const SizedBox(height: 10),
                    _buildInfoRow(
                      'Tahun Lahir',
                      birthYear.toString(),
                      lightGreenText,
                    ),
                    const SizedBox(height: 10),
                    _buildInfoRow(
                      'Tinggi Badan',
                      '${height.round()} cm',
                      lightGreenText,
                    ),
                    const SizedBox(height: 10),
                    _buildInfoRow(
                      'Berat Badan',
                      '${weight.round()} kg',
                      lightGreenText,
                    ),
                    const SizedBox(height: 10),
                    _buildInfoRow(
                      'Tingkat Aktivitas',
                      activityLevel,
                      lightGreenText,
                    ),
                    const SizedBox(height: 10),
                    _buildInfoRow(
                      'Tujuan',
                      goal.replaceAll(RegExp(r'\s*\([^)]*\)\s*'), ''),
                      lightGreenText,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  // Pastikan data profil telah disimpan sebelum navigasi
                  await _saveUserProfile();
                  Navigator.pushAndRemoveUntil(
                    context,
                    CustomPageRoute(
                      child: const DashboardScreen(),
                      backgroundColor: const Color(0xFF1D362C),
                    ),
                    (Route<dynamic> route) => false,
                  );
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
                  'Selesai',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.center,
              child: TextButton(
                onPressed: () async {
                  Navigator.pushAndRemoveUntil(
                    context,
                    CustomPageRoute(
                      child: const InputNameScreen(),
                      backgroundColor: const Color(0xFF1D362C),
                    ),
                    (Route<dynamic> route) => false,
                  );
                },
                style: TextButton.styleFrom(
                  foregroundColor: lightGreenText,
                  padding: EdgeInsets.zero,
                ),
                child: Text(
                  'Ubah data?',
                  style: TextStyle(
                    color: lightGreenText,
                    fontSize: 14,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, Color textColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 16, color: textColor.withOpacity(0.8)),
        ),
        Flexible(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildMacronutrientColumn(
    String label,
    int grams,
    Color textColor,
    Color bgColor,
  ) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 16, color: textColor.withOpacity(0.8)),
        ),
        const SizedBox(height: 5),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: bgColor, // Use the background color
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: textColor, width: 2),
          ),
          child: Text(
            '${grams}g',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ),
      ],
    );
  }
}
