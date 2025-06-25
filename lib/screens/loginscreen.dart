import 'package:flutter/material.dart';
import 'package:flutter_application_rpl_final/screens/dashboardscreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Fungsi untuk menghapus semua data riwayat pengguna yang ada
  // Duplikasi dari RegistrationScreen untuk memastikan reset pada login juga.
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
    print('Semua data riwayat (berat badan, makanan khusus, dan harian) telah dihapus saat login.');
  }

  Future<void> _loginUser() async {
    if (_formKey.currentState!.validate()) {
      final prefs = await SharedPreferences.getInstance();
      final String? storedEmail = prefs.getString('registered_email');
      final String? storedPassword = prefs.getString('registered_password');

      print('DEBUG: Login - User input email: ${_emailController.text}');
      print('DEBUG: Login - User input password: ${_passwordController.text}');
      print('DEBUG: Login - Stored email: $storedEmail');
      print('DEBUG: Login - Stored password: $storedPassword');

      if (_emailController.text == storedEmail && _passwordController.text == storedPassword) {
        // Login berhasil, hapus semua data riwayat yang ada untuk awal yang baru
        await _clearAllHistoryData();

        // Navigasi ke DashboardScreen
        // Asumsi kita ingin membersihkan stack navigasi agar pengguna tidak bisa kembali ke halaman login/register
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const DashboardScreen(),
          ),
          (Route<dynamic> route) => false,
        );
      } else {
        // Login gagal, tampilkan pesan kesalahan
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email atau kata sandi salah.'),
            backgroundColor: Colors.redAccent,
          ),
        );
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
                'Selamat Datang',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: lightGreenText,
                ),
              ),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Kembali! ',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: lightGreenText,
                      ),
                    ),
                    TextSpan(
                      text: '👋',
                      style: TextStyle(fontSize: 36),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Lanjutkan progress kamu dan capai target yang sudah dimulai!',
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
              const SizedBox(height: 10),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: 24, // Checkbox default size
                        height: 24,
                        child: Checkbox(
                          value: _rememberMe,
                          onChanged: (bool? newValue) {
                            setState(() {
                              _rememberMe = newValue!;
                            });
                          },
                          fillColor: WidgetStateProperty.resolveWith<Color>(
                            (Set<WidgetState> states) {
                              if (states.contains(WidgetState.selected)) {
                                return lightGreenText; // Warna ketika terpilih
                              }
                              return Colors.transparent; // Warna ketika tidak terpilih
                            },
                          ),
                          side: BorderSide(color: lightGreenText), // Warna border checkbox
                          checkColor: darkText, // Warna tanda centang
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Ingat saya',
                        style: TextStyle(color: lightGreenText, fontSize: 14),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () {
                      // TODO: Navigasi ke halaman lupa kata sandi
                      print('Lupa kata sandi ditekan');
                    },
                    child: Text(
                      'Lupa kata sandi',
                      style: TextStyle(color: lightGreenText, fontSize: 14),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loginUser,
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