import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_rpl_final/screens/welcomescreen_2.dart';
import 'dart:convert'; // Untuk JSON encode/decode
import 'dart:io'; // Untuk File
import 'package:path_provider/path_provider.dart'; // Untuk mendapatkan path direktori
import 'package:file_picker/file_picker.dart'; // Untuk memilih file

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Hapus semua data di SharedPreferences
    print('User data cleared and logged out.');

    // Navigasi ke WelcomeScreen2 dan hapus semua rute sebelumnya
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const WelcomeScreen2(),
      ),
      (Route<dynamic> route) => false,
    );
  }

  Future<void> _clearAllAppData() async {
    final prefs = await SharedPreferences.getInstance();

    // Hapus data registrasi/login
    await prefs.remove('registered_email');
    await prefs.remove('registered_password');
    await prefs.remove('user_profile_data'); // Hapus juga data profil pengguna

    // Hapus entri berat badan dan makanan khusus
    await prefs.remove('all_weight_entries');
    await prefs.remove('user_food_entries');

    // Hapus entri makanan dan aktivitas harian untuk rentang waktu yang masuk akal
    DateTime now = DateTime.now();
    for (int i = -365; i <= 7; i++) { // Dari 365 hari yang lalu hingga 7 hari ke depan
      DateTime date = DateTime(now.year, now.month, now.day).add(Duration(days: i));
      String dateKey = "entries_${date.year}_${date.month}_${date.day}";
      await prefs.remove('${dateKey}_food');
      await prefs.remove('${dateKey}_activity');
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Semua data aplikasi telah dihapus.'),
        backgroundColor: Colors.green,
      ),
    );
    print('Semua data aplikasi telah dihapus (tidak termasuk data registrasi jika ingin mempertahankan). Membutuhkan restart aplikasi.');

    // Opsional: Langsung logout setelah menghapus data, atau biarkan pengguna restart secara manual
    _logout(); // Mengasumsikan Anda ingin logout setelah menghapus semua data
  }

  Future<void> _exportUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Mengambil semua kunci dan nilainya dari SharedPreferences
      // Pastikan untuk menangani berbagai tipe data dengan benar
      final Map<String, dynamic> allData = {};
      for (String key in prefs.getKeys()) {
        allData[key] = prefs.get(key);
      }
      final String jsonString = jsonEncode(allData);

      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/calorie_tracker_data.json';
      final file = File(filePath);
      await file.writeAsString(jsonString);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Data berhasil diekspor ke: $filePath'),
            backgroundColor: Colors.green),
      );
      print('Data berhasil diekspor ke: $filePath');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Gagal mengekspor data: $e'),
            backgroundColor: Colors.redAccent),
      );
      print('Gagal mengekspor data: $e');
    }
  }

  Future<void> _importUserData() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null) {
        File file = File(result.files.single.path!);
        String jsonString = await file.readAsString();
        final Map<String, dynamic> importedData = jsonDecode(jsonString);

        final prefs = await SharedPreferences.getInstance();
        await prefs.clear(); // Hapus data lama sebelum mengimpor yang baru

        for (var entry in importedData.entries) {
          final key = entry.key;
          final value = entry.value;

          if (value is String) {
            await prefs.setString(key, value);
          } else if (value is int) {
            await prefs.setInt(key, value);
          } else if (value is bool) {
            await prefs.setBool(key, value);
          } else if (value is double) {
            await prefs.setDouble(key, value);
          } else if (value is List) { // Handle List of dynamic, then convert to List<String>
            await prefs.setStringList(key, value.map((e) => e.toString()).toList());
          } else {
            print('Tipe data tidak didukung untuk key $key: ${value.runtimeType}');
          }
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Data berhasil diimpor! Aplikasi akan dimulai ulang.'),
              backgroundColor: Colors.green),
        );
        print('Data berhasil diimpor.');

        // Restart aplikasi (atau navigasi ulang ke WelcomeScreen untuk memuat ulang data)
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const WelcomeScreen2()),
          (Route<dynamic> route) => false,
        );
      } else {
        // Pengguna membatalkan pemilihan file
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pemilihan file dibatalkan.'), backgroundColor: Colors.orangeAccent),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Gagal mengimpor data: $e'),
            backgroundColor: Colors.redAccent),
      );
      print('Gagal mengimpor data: $e');
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
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: lightGreenText),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Pengaturan',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: lightGreenText,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _exportUserData, // Tombol Ekspor Data
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: lightGreenText, // Warna hijau
                  foregroundColor: darkText,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Ekspor Data',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _importUserData, // Tombol Impor Data
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: lightGreenText, // Warna hijau
                  foregroundColor: darkText,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Impor Data',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Tombol Hapus Semua Data Aplikasi
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  // Konfirmasi pengguna sebelum menghapus semua data
                  bool? confirm = await showDialog<bool>(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        backgroundColor: darkGreenBg, // Sesuaikan dengan tema Anda
                        title: Text('Konfirmasi Penghapusan Data', style: TextStyle(color: lightGreenText)),
                        content: Text('Apakah Anda yakin ingin menghapus SEMUA data aplikasi? Tindakan ini tidak dapat dibatalkan.', style: TextStyle(color: lightGreenText.withOpacity(0.8))),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false), // Tidak jadi
                            child: Text('Batal', style: TextStyle(color: lightGreenText)),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true), // Ya, hapus
                            child: Text('Hapus', style: TextStyle(color: Colors.redAccent)),
                          ),
                        ],
                      );
                    },
                  );
                  if (confirm == true) {
                    await _clearAllAppData();
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.orangeAccent, // Warna peringatan
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Hapus Semua Data Aplikasi',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Tombol Logout
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _logout,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.redAccent, // Warna merah untuk tombol logout
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Logout',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Opsi lain akan datang di sini...',
              style: TextStyle(fontSize: 16, color: lightGreenText.withOpacity(0.7)),
            ),
          ],
        ),
      ),
    );
  }
} 