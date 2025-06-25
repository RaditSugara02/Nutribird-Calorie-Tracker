import 'package:flutter/material.dart';
import 'package:flutter_application_rpl_final/screens/inputactivitylevelscreen.dart';
import 'package:flutter_application_rpl_final/widgets/progress_bar.dart';

class InputWeightScreen extends StatefulWidget {
  final String name;
  final String gender;
  final int birthDay;
  final int birthMonth;
  final int birthYear;
  final double height;
  final String email;
  final String password;

  const InputWeightScreen({
    super.key,
    required this.name,
    required this.gender,
    required this.birthDay,
    required this.birthMonth,
    required this.birthYear,
    required this.height,
    required this.email,
    required this.password,
  });

  @override
  State<InputWeightScreen> createState() => _InputWeightScreenState();
}

class _InputWeightScreenState extends State<InputWeightScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _weightController = TextEditingController();

  @override
  void dispose() {
    _weightController.dispose();
    super.dispose();
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
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 20.0), // Adjust padding as needed
                      child: ProgressBar(currentStep: 5, totalSteps: 7),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                'Berapa berat badan Anda?',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: lightGreenText,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Informasi berat badan membantu kami menghitung kebutuhan kalori Anda.',
                style: TextStyle(
                  fontSize: 16,
                  color: lightGreenText.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 40),
              Text(
                'Berat Badan (kg)',
                style: TextStyle(fontSize: 14, color: lightGreenText),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _weightController,
                style: TextStyle(color: lightGreenText),
                decoration: InputDecoration(
                  hintText: 'Contoh: 60',
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
                  prefixIcon: Icon(Icons.fitness_center, color: lightGreenText),
                  suffixText: 'kg',
                  suffixStyle: TextStyle(color: lightGreenText),
                  errorStyle: TextStyle(color: Colors.redAccent),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Berat badan tidak boleh kosong';
                  }
                  final double? weight = double.tryParse(value);
                  if (weight == null) {
                    return 'Masukkan angka yang valid';
                  }
                  if (weight < 1 || weight > 600) {
                    return 'Berat badan harus antara 1 kg dan 600 kg';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => InputActivityLevelScreen(
                            name: widget.name,
                            gender: widget.gender,
                            birthDay: widget.birthDay,
                            birthMonth: widget.birthMonth,
                            birthYear: widget.birthYear,
                            height: widget.height,
                            weight: double.parse(_weightController.text),
                            email: widget.email,
                            password: widget.password,
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
      ),
    );
  }
} 