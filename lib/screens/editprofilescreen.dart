import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  Map<String, dynamic>? _userProfileData;
  final _nameController = TextEditingController();
  String? _selectedGender;
  final _birthYearController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  String? _selectedActivityLevel;
  String? _selectedGoal;

  final List<String> _genders = ['Laki-laki', 'Perempuan'];
  final List<String> _activityLevels = [
    'Sangat Sedentari',
    'Ringan Aktif',
    'Cukup Aktif',
    'Sangat Aktif',
    'Ekstra Aktif',
  ];
  final List<String> _goals = [
    'Menjaga Berat Badan',
    'Menurunkan Berat Badan Ringan (0.25 kg/minggu)',
    'Menurunkan Berat Badan Sedang (0.5 kg/minggu)',
    'Menurunkan Berat Badan Ekstrim (1 kg/minggu)',
    'Menambah Berat Badan',
  ];

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final String? profileJson = prefs.getString('user_profile_data');

    if (profileJson != null) {
      setState(() {
        _userProfileData = jsonDecode(profileJson);
        _nameController.text = _userProfileData!['name'] ?? '';
        _selectedGender = _userProfileData!['gender'];
        _birthYearController.text = '${_userProfileData!['birthYear'] ?? ''}';
        _heightController.text = '${_userProfileData!['height'] ?? ''}';
        _weightController.text = '${_userProfileData!['weight'] ?? ''}';
        _selectedActivityLevel = _userProfileData!['activityLevel'];
        _selectedGoal = _userProfileData!['goal'];
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _birthYearController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color darkGreenBg = const Color(0xFF1D362C);
    final Color lightGreenText = const Color(0xFFA2F46E);
    final Color darkText = const Color(0xFF000000);

    return Scaffold(
      backgroundColor: darkGreenBg,
      appBar: AppBar(
        backgroundColor: darkGreenBg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: lightGreenText),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          'Ubah Informasi Pribadi',
          style: TextStyle(
            color: lightGreenText,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: _userProfileData == null
          ? Center(
              child: Text(
                'Memuat data profil...',
                style: TextStyle(color: lightGreenText, fontSize: 18),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTextField(
                    'Nama Lengkap',
                    _nameController,
                    keyboardType: TextInputType.text,
                  ),
                  const SizedBox(height: 16),
                  _buildDropdownField('Gender', _genders, _selectedGender, (
                    String? newValue,
                  ) {
                    setState(() {
                      _selectedGender = newValue;
                    });
                  }),
                  const SizedBox(height: 16),
                  _buildTextField(
                    'Tahun Lahir',
                    _birthYearController,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    'Tinggi Badan (cm)',
                    _heightController,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    'Berat Badan (kg)',
                    _weightController,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  _buildDropdownField(
                    'Tingkat Aktivitas',
                    _activityLevels,
                    _selectedActivityLevel,
                    (String? newValue) {
                      setState(() {
                        _selectedActivityLevel = newValue;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildDropdownField('Tujuan', _goals, _selectedGoal, (
                    String? newValue,
                  ) {
                    setState(() {
                      _selectedGoal = newValue;
                    });
                  }),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        _saveProfile();
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
                        'Simpan Perubahan',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    final Color darkGreenBg = const Color(0xFF1D362C);
    final Color lightGreenText = const Color(0xFFA2F46E);

    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(color: lightGreenText, fontSize: 16),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: lightGreenText.withOpacity(0.7)),
        filled: true,
        fillColor: darkGreenBg.withOpacity(0.5),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: lightGreenText, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: lightGreenText, width: 2),
        ),
      ),
    );
  }

  Widget _buildDropdownField(
    String label,
    List<String> items,
    String? selectedValue,
    ValueChanged<String?> onChanged,
  ) {
    final Color darkGreenBg = const Color(0xFF1D362C);
    final Color lightGreenText = const Color(0xFFA2F46E);

    return DropdownButtonFormField<String>(
      initialValue: selectedValue,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: lightGreenText.withOpacity(0.7)),
        filled: true,
        fillColor: darkGreenBg.withOpacity(0.5),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: lightGreenText, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: lightGreenText, width: 2),
        ),
      ),
      dropdownColor: darkGreenBg,
      style: TextStyle(color: lightGreenText, fontSize: 16),
      items: items.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value, overflow: TextOverflow.ellipsis, maxLines: 1),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  Map<String, dynamic> _calculateDailyCaloriesAndMacros(
    Map<String, dynamic> profileData,
  ) {
    final String gender = profileData['gender'] ?? '';
    final double height = profileData['height'] ?? 0.0;
    final double weight = profileData['weight'] ?? 0.0;
    final String activityLevel = profileData['activityLevel'] ?? '';
    final String goal = profileData['goal'] ?? '';
    final int birthYear = profileData['birthYear'] ?? DateTime.now().year;

    final int currentYear = DateTime.now().year;
    final int age = currentYear - birthYear;

    double bmr;
    if (gender == 'Laki-laki') {
      bmr = (10 * weight) + (6.25 * height) - (5 * age) + 5;
    } else {
      bmr = (10 * weight) + (6.25 * height) - (5 * age) - 161;
    }

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
        activityFactor = 1.2;
    }
    double tdee = bmr * activityFactor;

    double dailyCalories;
    switch (goal) {
      case 'Menjaga Berat Badan':
        dailyCalories = tdee;
        break;
      case 'Menurunkan Berat Badan Ringan (0.25 kg/minggu)':
        dailyCalories = tdee - 250;
        break;
      case 'Menurunkan Berat Badan Sedang (0.5 kg/minggu)':
        dailyCalories = tdee - 500;
        break;
      case 'Menurunkan Berat Badan Ekstrim (1 kg/minggu)':
        dailyCalories = tdee - 1000;
        break;
      case 'Menambah Berat Badan':
        dailyCalories = tdee + 500;
        break;
      default:
        dailyCalories = tdee;
    }

    if (gender == 'Perempuan' && dailyCalories < 1200) dailyCalories = 1200;
    if (gender == 'Laki-laki' && dailyCalories < 1500) dailyCalories = 1500;

    final double proteinGrams = (dailyCalories * 0.20) / 4;
    final double fatGrams = (dailyCalories * 0.30) / 9;
    final double carbGrams = (dailyCalories * 0.50) / 4;

    return {
      'dailyCalories': dailyCalories.round(),
      'proteinGrams': proteinGrams.round(),
      'fatGrams': fatGrams.round(),
      'carbGrams': carbGrams.round(),
    };
  }

  Future<void> _saveProfile() async {
    final prefs = await SharedPreferences.getInstance();

    final newProfileData = {
      'name': _nameController.text,
      'gender': _selectedGender,
      'birthYear': int.tryParse(_birthYearController.text),
      'height': double.tryParse(_heightController.text),
      'weight': double.tryParse(_weightController.text),
      'activityLevel': _selectedActivityLevel,
      'goal': _selectedGoal,
    };

    // Selalu hitung ulang kalori dan makro berdasarkan data baru
    final recalculatedMacros = _calculateDailyCaloriesAndMacros(newProfileData);
    print(
      'EditProfileScreen: Recalculated Macros: $recalculatedMacros',
    ); // Debug log
    newProfileData.addAll(recalculatedMacros);
    print(
      'EditProfileScreen: New Profile Data (before saving): $newProfileData',
    ); // Debug log

    bool showRecalculateWarning = false;
    if (_userProfileData != null) {
      if (newProfileData['height'] != _userProfileData!['height'] ||
          newProfileData['weight'] != _userProfileData!['weight'] ||
          newProfileData['activityLevel'] !=
              _userProfileData!['activityLevel'] ||
          newProfileData['goal'] != _userProfileData!['goal'] ||
          newProfileData['gender'] != _userProfileData!['gender'] ||
          newProfileData['birthYear'] != _userProfileData!['birthYear']) {
        showRecalculateWarning = true;
      }
    }

    if (showRecalculateWarning) {
      final bool confirm =
          await showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                backgroundColor: const Color(0xFF1D362C),
                title: Text(
                  'Konfirmasi Perubahan',
                  style: TextStyle(color: const Color(0xFFA2F46E)),
                ),
                content: Text(
                  'Perubahan ini akan mempengaruhi rencana kalori & makro harian Anda. Lanjutkan?',
                  style: TextStyle(
                    color: const Color(0xFFA2F46E).withOpacity(0.8),
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text(
                      'Tidak',
                      style: TextStyle(
                        color: const Color(0xFFA2F46E).withOpacity(0.7),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: Text(
                      'Ya',
                      style: TextStyle(color: const Color(0xFFA2F46E)),
                    ),
                  ),
                ],
              );
            },
          ) ??
          false;

      if (!confirm) {
        return;
      }
    }

    await prefs.setString('user_profile_data', jsonEncode(newProfileData));

    // Kembali ke halaman sebelumnya dan beri tahu bahwa perubahan berhasil disimpan
    Navigator.of(context).pop(true);
  }
}
