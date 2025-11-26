import 'package:flutter/material.dart';
import 'package:flutter_application_rpl_final/screens/welcomescreen_1.dart';
import 'package:flutter_application_rpl_final/screens/dashboardscreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FutureBuilder<bool>(
        future: _hasExistingProfile(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (snapshot.hasData && snapshot.data == true) {
            return const DashboardScreen();
          }

          return const WelcomeScreen1();
        },
      ),
    );
  }

  Future<bool> _hasExistingProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final profile = prefs.getString('user_profile_data');
    return profile != null && profile.isNotEmpty;
  }
}
