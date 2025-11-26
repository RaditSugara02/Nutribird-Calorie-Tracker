import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_application_rpl_final/screens/editprofilescreen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_application_rpl_final/widgets/sound_helper.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _userProfileData;
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  void refreshProfile() {
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final String? profileJson = prefs.getString('user_profile_data');

    if (profileJson != null) {
      // Check if widget is still mounted before calling setState
      if (!mounted) return;

      setState(() {
        _userProfileData = jsonDecode(profileJson);
        // Load profile image path
        final String? imagePath = _userProfileData!['profileImagePath'];
        if (imagePath != null && imagePath.isNotEmpty) {
          _profileImage = File(imagePath);
          // Check if file exists
          if (!_profileImage!.existsSync()) {
            _profileImage = null;
          }
        }
      });
    }
  }

  Future<void> _pickProfileImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85, // Compress image to 85% quality
        maxWidth: 512, // Resize to max 512px width (maintains 1:1 ratio better)
        maxHeight: 512, // Resize to max 512px height
      );

      if (pickedFile != null) {
        final appDocDir = await getApplicationDocumentsDirectory();
        final String uniqueFileName =
            'profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final File newImage = File(pickedFile.path);
        final File savedImage = await newImage.copy(
          '${appDocDir.path}/$uniqueFileName',
        );

        // Update profile data with new image path
        if (_userProfileData != null) {
          _userProfileData!['profileImagePath'] = savedImage.path;
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(
            'user_profile_data',
            jsonEncode(_userProfileData),
          );
        }

        // Check if widget is still mounted before calling setState
        if (!mounted) return;

        setState(() {
          _profileImage = savedImage;
        });

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Foto profil berhasil diubah'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengubah foto profil: $e'),
          backgroundColor: Colors.redAccent,
          duration: Duration(seconds: 3),
        ),
      );
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
        toolbarHeight: 0, // Remove AppBar height completely
      ),
      body: SafeArea(
        child: _userProfileData == null
            ? Center(
                child: Text(
                  'Memuat data profil...',
                  style: TextStyle(
                    fontSize: 18,
                    color: lightGreenText.withOpacity(0.7),
                  ),
                ),
              )
            : SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  24.0,
                  8.0,
                  24.0,
                  8.0,
                ), // Further reduced top padding
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Foto Profil dengan kemampuan untuk upload
                    GestureDetector(
                      onTap: _pickProfileImage,
                      child: Stack(
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: lightGreenText,
                                width: 3,
                              ),
                              color: darkGreenBg,
                            ),
                            child: ClipOval(
                              child:
                                  _profileImage != null &&
                                      _profileImage!.existsSync()
                                  ? Image.file(
                                      _profileImage!,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                            return Icon(
                                              Icons.person,
                                              size: 80,
                                              color: lightGreenText,
                                            );
                                          },
                                    )
                                  : Icon(
                                      Icons.person,
                                      size: 80,
                                      color: lightGreenText,
                                    ),
                            ),
                          ),
                          // Icon kamera di pojok kanan bawah
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: lightGreenText,
                                border: Border.all(
                                  color: darkGreenBg,
                                  width: 3,
                                ),
                              ),
                              child: Icon(
                                Icons.camera_alt,
                                size: 20,
                                color: darkText,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Ketuk untuk mengubah foto',
                      style: TextStyle(
                        fontSize: 12,
                        color: lightGreenText.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 8),
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
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: lightGreenText,
                              ),
                            ),
                            const SizedBox(height: 15),
                            _buildInfoRow(
                              'Nama Lengkap',
                              _userProfileData!['name'] ?? '-',
                              lightGreenText,
                            ),
                            const SizedBox(height: 10),
                            _buildInfoRow(
                              'Gender',
                              _userProfileData!['gender'] ?? '-',
                              lightGreenText,
                            ),
                            const SizedBox(height: 10),
                            _buildInfoRow(
                              'Tahun Lahir',
                              '${_userProfileData!['birthYear'] ?? '-'}',
                              lightGreenText,
                            ),
                            const SizedBox(height: 10),
                            _buildInfoRow(
                              'Tinggi Badan',
                              '${_userProfileData!['height']?.round() ?? '-'} cm',
                              lightGreenText,
                            ),
                            const SizedBox(height: 10),
                            _buildInfoRow(
                              'Berat Badan',
                              '${_userProfileData!['weight']?.round() ?? '-'} kg',
                              lightGreenText,
                            ),
                            const SizedBox(height: 10),
                            _buildInfoRow(
                              'Tingkat Aktivitas',
                              _userProfileData!['activityLevel'] ?? '-',
                              lightGreenText,
                            ),
                            const SizedBox(height: 10),
                            _buildInfoRow(
                              'Tujuan',
                              _userProfileData!['goal']
                                      ?.replaceAll('(0.25 kg/minggu)', '')
                                      .replaceAll('(0.5 kg/minggu)', '')
                                      .replaceAll('(1 kg/minggu)', '')
                                      .trim() ??
                                  '-',
                              lightGreenText,
                            ),
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
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: lightGreenText,
                              ),
                            ),
                            const SizedBox(height: 15),
                            _buildInfoRow(
                              'Kalori Harian',
                              '${_userProfileData!['dailyCalories'] ?? '-'} kcal',
                              lightGreenText,
                            ),
                            const SizedBox(height: 10),
                            _buildInfoRow(
                              'Protein',
                              '${_userProfileData!['proteinGrams'] ?? '-'} g',
                              lightGreenText,
                            ),
                            const SizedBox(height: 10),
                            _buildInfoRow(
                              'Lemak',
                              '${_userProfileData!['fatGrams'] ?? '-'} g',
                              lightGreenText,
                            ),
                            const SizedBox(height: 10),
                            _buildInfoRow(
                              'Karbohidrat',
                              '${_userProfileData!['carbGrams'] ?? '-'} g',
                              lightGreenText,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          await SoundHelper.playTransition();
                          if (!mounted) return;
                          final result = await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const EditProfileScreen(),
                            ),
                          );
                          // Wait a bit to ensure navigation is complete
                          await Future.delayed(Duration(milliseconds: 100));
                          if (result == true && mounted) {
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
}
