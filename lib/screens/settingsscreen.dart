import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_rpl_final/screens/welcomescreen_1.dart';
import 'package:flutter_application_rpl_final/services/background_music_service.dart';
import 'package:flutter_application_rpl_final/utils/logger.dart';
import 'package:flutter_application_rpl_final/utils/error_handler.dart';
import 'package:flutter_application_rpl_final/widgets/loading_overlay.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_application_rpl_final/widgets/custom_page_route.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final BackgroundMusicService _musicService = BackgroundMusicService();
  bool _isMusicEnabled = false; // Default: music is off
  bool _isExporting = false;
  bool _isImporting = false;

  @override
  void initState() {
    super.initState();
    _loadMusicPreference();
  }

  Future<void> _loadMusicPreference() async {
    final isEnabled = _musicService.isEnabled;
    if (!mounted) return;
    setState(() {
      _isMusicEnabled = isEnabled;
    });
  }

  Future<void> _toggleMusic(bool value) async {
    if (!mounted) return;

    // Update UI dulu supaya animasi switch berjalan mulus
    setState(() {
      _isMusicEnabled = value;
    });

    // Setelah itu baru sinkronkan dengan service (bisa agak terlambat sedikit)
    await _musicService.toggle();
  }

  Future<void> _logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear(); // Hapus semua data di SharedPreferences
      AppLogger.info('User data cleared and logged out');

      // Navigasi ke WelcomeScreen1 dan hapus semua rute sebelumnya
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          CustomPageRoute(
            child: const WelcomeScreen1(),
            backgroundColor: Colors.transparent,
          ),
          (Route<dynamic> route) => false,
        );
      }
    } catch (e, stackTrace) {
      ErrorHandler.handleError(
        context,
        e,
        stackTrace,
        customMessage: 'Gagal melakukan logout',
      );
    }
  }

  Future<void> _clearAllAppData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Hapus data profil pengguna
      await prefs.remove('user_profile_data');

      // Hapus entri berat badan dan makanan khusus
      await prefs.remove('all_weight_entries');
      await prefs.remove('user_food_entries');

      // Hapus entri makanan dan aktivitas harian untuk rentang waktu yang masuk akal
      DateTime now = DateTime.now();
      for (int i = -365; i <= 7; i++) {
        // Dari 365 hari yang lalu hingga 7 hari ke depan
        DateTime date = DateTime(
          now.year,
          now.month,
          now.day,
        ).add(Duration(days: i));
        String dateKey = "entries_${date.year}_${date.month}_${date.day}";
        await prefs.remove('${dateKey}_food');
        await prefs.remove('${dateKey}_activity');
      }

      AppLogger.info('All app data cleared');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Semua data aplikasi telah dihapus.'),
            backgroundColor: Colors.green,
          ),
        );
      }

      // Opsional: Langsung logout setelah menghapus data, atau biarkan pengguna restart secara manual
      _logout(); // Mengasumsikan Anda ingin logout setelah menghapus semua data
    } catch (e, stackTrace) {
      ErrorHandler.handleError(
        context,
        e,
        stackTrace,
        customMessage: 'Gagal menghapus data aplikasi',
      );
    }
  }

  Future<void> _exportUserData() async {
    if (_isExporting) return;

    setState(() {
      _isExporting = true;
    });

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

      AppLogger.info('Data exported successfully to: $filePath');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Data berhasil diekspor ke: $filePath'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e, stackTrace) {
      AppLogger.error('Failed to export data', e, stackTrace);
      if (mounted) {
        ErrorHandler.handleError(
          context,
          e,
          stackTrace,
          customMessage: 'Gagal mengekspor data',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isExporting = false;
        });
      }
    }
  }

  Future<void> _importUserData() async {
    if (_isImporting) return;

    // Konfirmasi sebelum import (karena akan overwrite data)
    final shouldImport = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1D362C),
          title: const Text(
            'Konfirmasi Import Data',
            style: TextStyle(
              color: Colors.orangeAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            'Import data akan menghapus semua data yang ada saat ini. Apakah Anda yakin?',
            style: TextStyle(color: Color(0xFFA2F46E)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                'Batal',
                style: TextStyle(color: Colors.redAccent),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text(
                'Ya, Import',
                style: TextStyle(color: Color(0xFFA2F46E)),
              ),
            ),
          ],
        );
      },
    );

    if (shouldImport != true) {
      return; // User membatalkan
    }

    setState(() {
      _isImporting = true;
    });

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null) {
        File file = File(result.files.single.path!);
        String jsonString = await file.readAsString();

        // Validasi format JSON sebelum decode
        try {
          jsonDecode(jsonString);
        } catch (e) {
          throw FormatException('File bukan format JSON yang valid');
        }

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
          } else if (value is List) {
            // Handle List of dynamic, then convert to List<String>
            await prefs.setStringList(
              key,
              value.map((e) => e.toString()).toList(),
            );
          } else {
            AppLogger.warning(
              'Unsupported data type for key $key: ${value.runtimeType}',
            );
          }
        }

        AppLogger.info('Data imported successfully');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Data berhasil diimpor! Aplikasi akan dimulai ulang.',
              ),
              backgroundColor: Colors.green,
            ),
          );
        }

        // Restart aplikasi (atau navigasi ulang ke WelcomeScreen untuk memuat ulang data)
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            CustomPageRoute(
              child: const WelcomeScreen1(),
              backgroundColor: Colors.transparent,
            ),
            (Route<dynamic> route) => false,
          );
        }
      } else {
        // Pengguna membatalkan pemilihan file
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Pemilihan file dibatalkan.'),
              backgroundColor: Colors.orangeAccent,
            ),
          );
        }
      }
    } catch (e, stackTrace) {
      AppLogger.error('Failed to import data', e, stackTrace);
      if (mounted) {
        ErrorHandler.handleError(
          context,
          e,
          stackTrace,
          customMessage:
              'Gagal mengimpor data. Pastikan file format JSON valid.',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isImporting = false;
        });
      }
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
          onPressed: () async {
            if (mounted) {
              Navigator.pop(context);
            }
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
      body: LoadingOverlay(
        isLoading: _isExporting || _isImporting,
        message: _isExporting
            ? 'Mengekspor data...'
            : _isImporting
            ? 'Mengimpor data...'
            : null,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (_isExporting || _isImporting)
                      ? null
                      : _exportUserData,
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
                  onPressed: (_isExporting || _isImporting)
                      ? null
                      : _importUserData,
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
                          backgroundColor:
                              darkGreenBg, // Sesuaikan dengan tema Anda
                          title: Text(
                            'Konfirmasi Penghapusan Data',
                            style: TextStyle(color: lightGreenText),
                          ),
                          content: Text(
                            'Apakah Anda yakin ingin menghapus SEMUA data aplikasi? Tindakan ini tidak dapat dibatalkan.',
                            style: TextStyle(
                              color: lightGreenText.withOpacity(0.8),
                            ),
                          ),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () => Navigator.of(
                                context,
                              ).pop(false), // Tidak jadi
                              child: Text(
                                'Batal',
                                style: TextStyle(color: lightGreenText),
                              ),
                            ),
                            TextButton(
                              onPressed: () =>
                                  Navigator.of(context).pop(true), // Ya, hapus
                              child: Text(
                                'Hapus',
                                style: TextStyle(color: Colors.redAccent),
                              ),
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
              // Toggle Background Music
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: darkGreenBg.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: lightGreenText.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _isMusicEnabled ? Icons.music_note : Icons.music_off,
                          color: lightGreenText,
                          size: 28,
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Musik Latar',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: lightGreenText,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _isMusicEnabled
                                  ? 'Musik sedang aktif'
                                  : 'Musik dimatikan',
                              style: TextStyle(
                                fontSize: 14,
                                color: lightGreenText.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Switch(
                      value: _isMusicEnabled,
                      onChanged: (value) => _toggleMusic(value),
                      activeColor: lightGreenText,
                      activeTrackColor: lightGreenText.withOpacity(0.5),
                      inactiveThumbColor: Colors.grey,
                      inactiveTrackColor: Colors.grey.withOpacity(0.3),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Opsi lain akan datang di sini...',
                style: TextStyle(
                  fontSize: 16,
                  color: lightGreenText.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
