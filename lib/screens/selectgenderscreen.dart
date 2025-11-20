import 'package:flutter/material.dart';
import 'package:flutter_application_rpl_final/screens/selectbirthyearscreen.dart';
import 'package:flutter_application_rpl_final/widgets/progress_bar.dart';

class SelectGenderScreen extends StatefulWidget {
  final String name;
  final String? email;
  final String? password;

  const SelectGenderScreen({
    super.key,
    required this.name,
    this.email,
    this.password,
  });

  @override
  State<SelectGenderScreen> createState() => _SelectGenderScreenState();
}

class _SelectGenderScreenState extends State<SelectGenderScreen> {
  String? _selectedGender;
  final _formKey = GlobalKey<FormState>();

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
                      padding: const EdgeInsets.only(
                        right: 20.0,
                      ), // Adjust padding as needed
                      child: ProgressBar(currentStep: 2, totalSteps: 7),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                'Apa jenis kelamin Anda?',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: lightGreenText,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Pilih jenis kelamin Anda untuk personalisasi yang lebih baik.',
                style: TextStyle(
                  fontSize: 16,
                  color: lightGreenText.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 40),
              Column(
                children: [
                  _buildGenderOption(context, 'Laki-laki', Icons.male),
                  const SizedBox(height: 20),
                  _buildGenderOption(context, 'Perempuan', Icons.female),
                ],
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_selectedGender == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Mohon pilih jenis kelamin Anda'),
                        ),
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SelectBirthYearScreen(
                            name: widget.name,
                            gender: _selectedGender!,
                            email: widget.email ?? '',
                            password: widget.password ?? '',
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

  Widget _buildGenderOption(
    BuildContext context,
    String gender,
    IconData icon,
  ) {
    final Color darkGreenBg = const Color(0xFF1D362C);
    final Color lightGreenText = const Color(0xFFA2F46E);
    final Color darkText = const Color(0xFF112D21);

    bool isSelected = _selectedGender == gender;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedGender = gender;
        });
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
        decoration: BoxDecoration(
          color: isSelected ? lightGreenText : darkGreenBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : lightGreenText, // Border always lightGreenText if not selected
            width: 2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              gender,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isSelected ? darkText : lightGreenText,
              ),
            ),
            Icon(icon, color: isSelected ? darkText : lightGreenText, size: 30),
          ],
        ),
      ),
    );
  }
}
