import 'package:flutter/material.dart';
import 'package:flutter_application_rpl_final/screens/selectgenderscreen.dart';
import 'package:flutter_application_rpl_final/widgets/progress_bar.dart';

class InputNameScreen extends StatefulWidget {
  final String email;
  final String password;

  const InputNameScreen({super.key, required this.email, required this.password});

  @override
  State<InputNameScreen> createState() => _InputNameScreenState();
}

class _InputNameScreenState extends State<InputNameScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
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
                      child: ProgressBar(currentStep: 1, totalSteps: 7),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                'Siapa nama Anda?',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: lightGreenText,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Langkah awal untuk personalisasi pengalaman Anda.',
                style: TextStyle(
                  fontSize: 16,
                  color: lightGreenText.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 40),
              Text(
                'Nama Lengkap',
                style: TextStyle(fontSize: 14, color: lightGreenText),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                style: TextStyle(color: lightGreenText),
                decoration: InputDecoration(
                  hintText: 'Nama Lengkap',
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
                  prefixIcon: Icon(Icons.person, color: lightGreenText),
                  errorStyle: TextStyle(color: Colors.redAccent),
                ),
                keyboardType: TextInputType.text,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama tidak boleh kosong';
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
                          builder: (context) => SelectGenderScreen(
                            name: _nameController.text,
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