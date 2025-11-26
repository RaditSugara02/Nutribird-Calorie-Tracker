import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_application_rpl_final/widgets/sound_helper.dart';
import 'package:lottie/lottie.dart';

class AddActivityScreen extends StatefulWidget {
  final Function(String activityName, int caloriesBurned)
  onActivityAdded; // Callback

  const AddActivityScreen({super.key, required this.onActivityAdded});

  @override
  State<AddActivityScreen> createState() => _AddActivityScreenState();
}

class _AddActivityScreenState extends State<AddActivityScreen> {
  final TextEditingController _activityNameController = TextEditingController();
  final TextEditingController _caloriesBurnedController =
      TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void dispose() {
    _activityNameController.dispose();
    _caloriesBurnedController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  // Fungsi untuk memutar suara error
  void _playErrorSound() {
    try {
      _audioPlayer.play(AssetSource('error.wav'));
    } catch (e) {
      print('Error playing sound: $e');
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
          'Tambah Aktivitas',
          style: TextStyle(
            color: lightGreenText,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            left: 24.0,
            right: 24.0,
            top: 24.0,
            bottom: 24.0 + MediaQuery.of(context).padding.bottom,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Animasi Lottie di atas
                SizedBox(
                  height: 200, // Ukuran sedang
                  width: 200,
                  child: Lottie.asset(
                    'assets/lottie/activity.json', // Path ke file Lottie JSON
                    fit: BoxFit.contain,
                    repeat: true, // Loop animasi
                    animate: true,
                  ),
                ),
                const SizedBox(
                  height: 20,
                ), // Jarak antara animasi dan form (bisa diubah: 10-30)
                // Form fields dimulai dari sini
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Nama Aktivitas',
                    style: TextStyle(fontSize: 16, color: lightGreenText),
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _activityNameController,
                  style: TextStyle(color: lightGreenText),
                  decoration: InputDecoration(
                    hintText: 'Contoh: Lari Pagi',
                    hintStyle: TextStyle(
                      color: lightGreenText.withOpacity(0.6),
                    ),
                    filled: true,
                    fillColor: darkGreenBg,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: lightGreenText),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: lightGreenText),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: lightGreenText, width: 2.0),
                    ),
                    errorStyle: TextStyle(color: Colors.redAccent),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      _playErrorSound();
                      return 'Nama aktivitas tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Kalori Dibakar (kcal)',
                    style: TextStyle(fontSize: 16, color: lightGreenText),
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _caloriesBurnedController,
                  style: TextStyle(color: lightGreenText),
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Contoh: 250',
                    hintStyle: TextStyle(
                      color: lightGreenText.withOpacity(0.6),
                    ),
                    filled: true,
                    fillColor: darkGreenBg,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: lightGreenText),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: lightGreenText),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: lightGreenText, width: 2.0),
                    ),
                    errorStyle: TextStyle(color: Colors.redAccent),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      _playErrorSound();
                      return 'Jumlah kalori tidak boleh kosong';
                    }
                    if (int.tryParse(value) == null || int.parse(value) <= 0) {
                      _playErrorSound();
                      return 'Masukkan angka kalori yang valid (> 0)';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        final String activityName =
                            _activityNameController.text;
                        final int caloriesBurned = int.parse(
                          _caloriesBurnedController.text,
                        );
                        widget.onActivityAdded(activityName, caloriesBurned);
                        // Play success sound ketika aktivitas berhasil ditambahkan
                        await SoundHelper.playSuccess();
                        await Future.delayed(const Duration(milliseconds: 300));
                        // Kembali tanpa transisi sound
                        if (mounted) {
                          Navigator.pop(context);
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
                      'Tambahkan Aktivitas',
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
      ),
    );
  }
}
