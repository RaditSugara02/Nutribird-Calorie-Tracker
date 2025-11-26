import 'package:flutter/material.dart';
import 'package:flutter_application_rpl_final/screens/inputweightscreen.dart';
import 'package:flutter_application_rpl_final/widgets/progress_bar.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_application_rpl_final/widgets/sound_helper.dart';
import 'package:flutter_application_rpl_final/widgets/custom_page_route.dart';

class InputHeightScreen extends StatefulWidget {
  final String name;
  final String gender;
  final int birthDay;
  final int birthMonth;
  final int birthYear;

  const InputHeightScreen({
    super.key,
    required this.name,
    required this.gender,
    required this.birthDay,
    required this.birthMonth,
    required this.birthYear,
  });

  @override
  State<InputHeightScreen> createState() => _InputHeightScreenState();
}

class _InputHeightScreenState extends State<InputHeightScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _heightController = TextEditingController();
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void dispose() {
    _heightController.dispose();
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
        child: Form(
          key: _formKey,
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
                      child: ProgressBar(currentStep: 4, totalSteps: 7),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                'Berapa tinggi badan Anda?',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: lightGreenText,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Informasi tinggi badan membantu kami menghitung kebutuhan kalori Anda.',
                style: TextStyle(
                  fontSize: 16,
                  color: lightGreenText.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 40),
              Text(
                'Tinggi Badan (cm)',
                style: TextStyle(fontSize: 14, color: lightGreenText),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _heightController,
                style: TextStyle(color: lightGreenText),
                decoration: InputDecoration(
                  hintText: 'Contoh: 170',
                  hintStyle: TextStyle(color: lightGreenText.withOpacity(0.6)),
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
                  prefixIcon: Icon(Icons.height, color: lightGreenText),
                  suffixText: 'cm',
                  suffixStyle: TextStyle(color: lightGreenText),
                  errorStyle: TextStyle(color: Colors.redAccent),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    _playErrorSound();
                    return 'Tinggi badan tidak boleh kosong';
                  }
                  final double? height = double.tryParse(value);
                  if (height == null) {
                    _playErrorSound();
                    return 'Masukkan angka yang valid';
                  }
                  if (height < 50 || height > 250) {
                    _playErrorSound();
                    return 'Tinggi badan harus antara 50 cm dan 250 cm';
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
                      if (mounted) {
                        Navigator.push(
                          context,
                          CustomPageRoute(
                            child: InputWeightScreen(
                              name: widget.name,
                              gender: widget.gender,
                              birthDay: widget.birthDay,
                              birthMonth: widget.birthMonth,
                              birthYear: widget.birthYear,
                              height: double.parse(_heightController.text),
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
      ),
    );
  }
}
