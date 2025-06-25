import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter_application_rpl_final/screens/editprofilescreen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _userProfileData;

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
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color darkGreenBg = const Color(0xFF1D362C);
    final Color lightGreenText = const Color(0xFFA2F46E);
    final Color darkText = const Color(0xFF112D21);

    return Scaffold(
      backgroundColor: darkGreenBg,
      appBar: AppBar(
        backgroundColor: darkGreenBg,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: null,
        centerTitle: false,
        toolbarHeight: 50.0,
      ),
      body: _userProfileData == null
          ? Center(
              child: Text(
                'Memuat data profil...',
                style: TextStyle(fontSize: 18, color: lightGreenText.withOpacity(0.7)),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.person,
                    size: 100,
                    color: lightGreenText,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _userProfileData!['name'] ?? 'Pengguna',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: lightGreenText,
                    ),
                    textAlign: TextAlign.center,
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
                            'Informasi Pribadi',
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: lightGreenText),
                          ),
                          const SizedBox(height: 15),
                          _buildInfoRow('Nama Lengkap', _userProfileData!['name'] ?? '-', lightGreenText),
                          const SizedBox(height: 10),
                          _buildInfoRow('Gender', _userProfileData!['gender'] ?? '-', lightGreenText),
                          const SizedBox(height: 10),
                          _buildInfoRow('Tahun Lahir', '${_userProfileData!['birthYear'] ?? '-'}', lightGreenText),
                          const SizedBox(height: 10),
                          _buildInfoRow('Tinggi Badan', '${_userProfileData!['height']?.round() ?? '-'} cm', lightGreenText),
                          const SizedBox(height: 10),
                          _buildInfoRow('Berat Badan', '${_userProfileData!['weight']?.round() ?? '-'} kg', lightGreenText),
                          const SizedBox(height: 10),
                          _buildInfoRow('Tingkat Aktivitas', _userProfileData!['activityLevel'] ?? '-', lightGreenText),
                          const SizedBox(height: 10),
                          _buildInfoRow('Tujuan', _userProfileData!['goal']?.replaceAll('(0.25 kg/minggu)', '').replaceAll('(0.5 kg/minggu)', '').replaceAll('(1 kg/minggu)', '').trim() ?? '-', lightGreenText),
                        ],
                      ),
                    ),
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
                            'Rencana Kalori & Makro',
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: lightGreenText),
                          ),
                          const SizedBox(height: 15),
                          _buildInfoRow('Kalori Harian', '${_userProfileData!['dailyCalories'] ?? '-'} kcal', lightGreenText),
                          const SizedBox(height: 10),
                          _buildInfoRow('Protein', '${_userProfileData!['proteinGrams'] ?? '-'} g', lightGreenText),
                          const SizedBox(height: 10),
                          _buildInfoRow('Lemak', '${_userProfileData!['fatGrams'] ?? '-'} g', lightGreenText),
                          const SizedBox(height: 10),
                          _buildInfoRow('Karbohidrat', '${_userProfileData!['carbGrams'] ?? '-'} g', lightGreenText),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        final result = await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const EditProfileScreen(),
                          ),
                        );
                        if (result == true) {
                          _loadUserProfile();
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
                        'Ubah Informasi Pribadi',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
} 