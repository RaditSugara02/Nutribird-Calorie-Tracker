import 'package:flutter/material.dart';
import 'package:flutter_application_rpl_final/screens/inputnamescreen.dart';
import 'package:flutter_application_rpl_final/screens/loginscreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Fungsi untuk menghapus semua data riwayat pengguna yang ada
  Future<void> _clearAllHistoryData() async {
    final prefs = await SharedPreferences.getInstance();
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
    print('Semua data riwayat (berat badan, makanan khusus, dan harian) telah dihapus.');
  }

  Future<void> _registerUser() async {
    if (_formKey.currentState!.validate()) {
      // Hapus semua data riwayat yang ada untuk awal yang baru bagi pengguna baru
      await _clearAllHistoryData();

      // Simpan email dan password ke SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('registered_email', _emailController.text);
      await prefs.setString('registered_password', _passwordController.text);
      print('DEBUG: Registration - Email saved: ${_emailController.text}');
      print('DEBUG: Registration - Password saved: ${_passwordController.text}');

      // Navigasi ke halaman berikutnya
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => InputNameScreen(
            email: _emailController.text,
            password: _passwordController.text,
          ),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back_ios, color: lightGreenText),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 20),
              Text(
                'Mulai Sekarang',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: lightGreenText,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Satu langkah kecil menuju hidup yang lebih sehat',
                style: TextStyle(
                  fontSize: 16,
                  color: lightGreenText.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 40),

              Text(
                'Email',
                style: TextStyle(fontSize: 14, color: lightGreenText),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _emailController,
                style: TextStyle(color: lightGreenText),
                decoration: InputDecoration(
                  hintText: 'Email',
                  hintStyle: TextStyle(color: lightGreenText.withOpacity(0.6)),
                  filled: true,
                  fillColor: darkGreenBg,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: lightGreenText), // Border color
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: lightGreenText),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: lightGreenText, width: 2.0),
                  ),
                  prefixIcon: Icon(Icons.email, color: lightGreenText),
                  errorStyle: TextStyle(color: Colors.redAccent),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Email tidak boleh kosong';
                  }
                  if (!RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(value)) {
                    return 'Masukkan format email yang valid';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              Text(
                'Kata Sandi',
                style: TextStyle(fontSize: 14, color: lightGreenText),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _passwordController,
                style: TextStyle(color: lightGreenText),
                decoration: InputDecoration(
                  hintText: 'Kata Sandi',
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
                  prefixIcon: Icon(Icons.lock, color: lightGreenText),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                      color: lightGreenText,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                  errorStyle: TextStyle(color: Colors.redAccent),
                ),
                obscureText: !_isPasswordVisible,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Kata Sandi tidak boleh kosong';
                  }
                  if (value.length < 6) {
                    return 'Kata Sandi minimal 6 karakter';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              Text(
                'Konfirmasi Kata Sandi',
                style: TextStyle(fontSize: 14, color: lightGreenText),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _confirmPasswordController,
                style: TextStyle(color: lightGreenText),
                decoration: InputDecoration(
                  hintText: 'Konfirmasi Kata Sandi',
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
                  prefixIcon: Icon(Icons.lock_outline, color: lightGreenText),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                      color: lightGreenText,
                    ),
                    onPressed: () {
                      setState(() {
                        _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                      });
                    },
                  ),
                  errorStyle: TextStyle(color: Colors.redAccent),
                ),
                obscureText: !_isConfirmPasswordVisible,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Konfirmasi Kata Sandi tidak boleh kosong';
                  }
                  if (value != _passwordController.text) {
                    return 'Kata Sandi tidak cocok';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              Align(
                alignment: Alignment.center,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                    );
                  },
                  child: RichText(
                    text: TextSpan(
                      text: 'Sudah punya akun? ',
                      style: TextStyle(
                        color: lightGreenText.withOpacity(0.8),
                        fontSize: 14,
                      ),
                      children: [
                        TextSpan(
                          text: 'Masuk',
                          style: TextStyle(
                            color: lightGreenText,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    _registerUser();
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