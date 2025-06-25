import 'package:flutter/material.dart';
import 'package:flutter_application_rpl_final/screens/statisticsscreen.dart';
import 'package:flutter_application_rpl_final/screens/profilescreen.dart';
import 'package:flutter_application_rpl_final/screens/addfoodscreen.dart';
import 'package:flutter_application_rpl_final/screens/addactivityscreen.dart';
import 'package:flutter_application_rpl_final/screens/addweightscreen.dart';
import 'package:flutter_application_rpl_final/screens/settingsscreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

// Kelas untuk merepresentasikan entri makanan
class FoodEntry {
  final String foodName;
  final int calories;
  final String mealType;
  final double? protein;
  final double? fat;
  final double? carb;
  final String? imagePath;

  FoodEntry({
    required this.foodName,
    required this.calories,
    required this.mealType,
    this.protein,
    this.fat,
    this.carb,
    this.imagePath,
  });

  // Konversi objek FoodEntry menjadi Map (untuk JSON)
  Map<String, dynamic> toJson() => {
        'foodName': foodName,
        'calories': calories,
        'mealType': mealType,
        'protein': protein,
        'fat': fat,
        'carb': carb,
        'imagePath': imagePath,
      };

  // Buat objek FoodEntry dari Map (dari JSON)
  factory FoodEntry.fromJson(Map<String, dynamic> json) {
    return FoodEntry(
      foodName: json['foodName'] as String,
      calories: json['calories'] as int,
      mealType: json['mealType'] as String,
      protein: json['protein'] as double?,
      fat: json['fat'] as double?,
      carb: json['carb'] as double?,
      imagePath: json['imagePath'] as String?,
    );
  }
}

// Kelas untuk merepresentasikan entri aktivitas
class ActivityEntry {
  final String activityName;
  final int caloriesBurned;

  ActivityEntry({
    required this.activityName,
    required this.caloriesBurned,
  });

  // Konversi objek ActivityEntry menjadi Map (untuk JSON)
  Map<String, dynamic> toJson() => {
        'activityName': activityName,
        'caloriesBurned': caloriesBurned,
      };

  // Buat objek ActivityEntry dari Map (dari JSON)
  factory ActivityEntry.fromJson(Map<String, dynamic> json) {
    return ActivityEntry(
      activityName: json['activityName'] as String,
      caloriesBurned: json['caloriesBurned'] as int,
    );
  }
}

// Kelas untuk merepresentasikan entri berat badan
class WeightEntry {
  final double weight;
  final DateTime date;

  WeightEntry({
    required this.weight,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
        'weight': weight,
        'date': date.toIso8601String(), // Simpan sebagai string ISO 8601
      };

  factory WeightEntry.fromJson(Map<String, dynamic> json) {
    return WeightEntry(
      weight: json['weight'] as double,
      date: DateTime.parse(json['date'] as String), // Parse dari string ISO 8601
    );
  }
}

class DashboardScreen extends StatefulWidget {
  // final int dailyCalories;
  // final int proteinGrams;
  // final int fatGrams;
  // final int carbGrams;

  const DashboardScreen({
    super.key,
    // required this.dailyCalories,
    // required this.proteinGrams,
    // required this.fatGrams,
    // required this.carbGrams,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0; // Untuk BottomNavigationBar
  late DateTime _currentDate;
  List<FoodEntry> _foodEntries = [];
  List<ActivityEntry> _activityEntries = [];
  List<WeightEntry> _weightEntries = [];
  int _caloriesConsumed = 0;
  int _caloriesBurned = 0;
  double _proteinConsumed = 0.0;
  double _fatConsumed = 0.0;
  double _carbConsumed = 0.0;

  // Variabel untuk menyimpan target kalori dan makro
  int _dailyCalories = 0;
  int _proteinGrams = 0;
  int _fatGrams = 0;
  int _carbGrams = 0;

  final GlobalKey<StatisticsScreenState> _statisticsScreenKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _currentDate = DateTime.now();
    _loadUserProfileAndEntries(); // Ganti nama fungsi untuk memuat profil juga
  }

  // Fungsi untuk mendapatkan kunci penyimpanan unik per tanggal
  String _getDateKey(DateTime date) {
    return "entries_${date.year}_${date.month}_${date.day}";
  }

  // Fungsi untuk memuat entri makanan, aktivitas, berat badan, dan data profil
  Future<void> _loadUserProfileAndEntries() async { // Ubah nama fungsi
    print('DashboardScreen: Loading all entries and user profile...');
    final prefs = await SharedPreferences.getInstance();
    final dateKey = _getDateKey(_currentDate);

    // Muat data profil pengguna
    final String? profileJson = prefs.getString('user_profile_data');
    if (profileJson != null) {
      final Map<String, dynamic> userProfileData = jsonDecode(profileJson);
      setState(() {
        _dailyCalories = userProfileData['dailyCalories'] ?? 0;
        _proteinGrams = userProfileData['proteinGrams'] ?? 0;
        _fatGrams = userProfileData['fatGrams'] ?? 0;
        _carbGrams = userProfileData['carbGrams'] ?? 0;
      });
      print('DashboardScreen: User profile data loaded: $_dailyCalories kcal');
    }

    // Muat entri makanan
    final List<String>? foodEntriesJson = prefs.getStringList('${dateKey}_food');
    setState(() {
      _foodEntries = foodEntriesJson
              ?.map((entryJson) => FoodEntry.fromJson(jsonDecode(entryJson)))
              .toList() ??
          [];
      _caloriesConsumed = _foodEntries.fold(0, (sum, entry) => sum + entry.calories);
      _proteinConsumed = _foodEntries.fold(0.0, (sum, entry) => sum + (entry.protein ?? 0.0));
      _fatConsumed = _foodEntries.fold(0.0, (sum, entry) => sum + (entry.fat ?? 0.0));
      _carbConsumed = _foodEntries.fold(0.0, (sum, entry) => sum + (entry.carb ?? 0.0));
      print('DashboardScreen: Food entries loaded: ${_foodEntries.length}');
    });

    // Muat entri aktivitas
    final List<String>? activityEntriesJson = prefs.getStringList('${dateKey}_activity');
    setState(() {
      _activityEntries = activityEntriesJson
              ?.map((entryJson) => ActivityEntry.fromJson(jsonDecode(entryJson)))
              .toList() ??
          [];
      _caloriesBurned = _activityEntries.fold(0, (sum, entry) => sum + entry.caloriesBurned);
      print('DashboardScreen: Activity entries loaded: ${_activityEntries.length}'); // Debug: Jumlah aktivitas
    });

    // Muat entri berat badan (tidak terkait dengan tanggal harian, jadi kunci terpisah atau semua riwayat)
    // Untuk saat ini, kita akan menyimpan semua riwayat berat badan dalam satu kunci terpisah
    final List<String>? weightEntriesJson = prefs.getStringList('all_weight_entries');
    print('DashboardScreen: Raw weight entries JSON from SharedPreferences (before processing): $weightEntriesJson'); // Debug: Tampilkan data mentah yang dimuat
    print('DashboardScreen: Raw weight entries JSON from SharedPreferences (after getStringList): $weightEntriesJson'); // Tambahkan log ini
    setState(() {
      _weightEntries = weightEntriesJson
              ?.map((entryJson) => WeightEntry.fromJson(jsonDecode(entryJson)))
              .toList() ??
          [];
      // Urutkan berat badan berdasarkan tanggal (terbaru di atas)
      _weightEntries.sort((a, b) => b.date.compareTo(a.date));
      print('DashboardScreen: Weight entries loaded into _weightEntries: ${_weightEntries.length}'); // Debug: Jumlah berat badan
    });
  }

  // Fungsi untuk menyimpan entri makanan, aktivitas, dan berat badan
  Future<void> _saveEntries() async { // Ubah nama fungsi
    final prefs = await SharedPreferences.getInstance();
    final dateKey = _getDateKey(_currentDate);

    // Simpan entri makanan
    final List<String> foodEntriesJson = _foodEntries.map((entry) => jsonEncode(entry.toJson())).toList();
    await prefs.setStringList('${dateKey}_food', foodEntriesJson);

    // Simpan entri aktivitas
    final List<String> activityEntriesJson = _activityEntries.map((entry) => jsonEncode(entry.toJson())).toList();
    await prefs.setStringList('${dateKey}_activity', activityEntriesJson);

    // Simpan entri berat badan
    print('DashboardScreen: _weightEntries in _saveEntries before JSON conversion: ${_weightEntries.map((e) => e.weight).toList()}'); // Tambahkan log ini
    final List<String> weightEntriesJson = _weightEntries.map((entry) => jsonEncode(entry.toJson())).toList();
    print('Saving weight entries JSON: $weightEntriesJson'); // Debug: Tampilkan data JSON yang akan disimpan
    print('DashboardScreen: Attempting to save weight entries JSON: $weightEntriesJson'); // Tambahkan log ini
    await prefs.setStringList('all_weight_entries', weightEntriesJson);
    print('Weight entries saved to SharedPreferences.'); // Debug: Konfirmasi penyimpanan
  }

  void _onItemTapped(int index) async { // Jadikan async
    setState(() {
      _selectedIndex = index;
    });
    // Pastikan data dashboard dimuat ulang saat berpindah tab
    await _loadUserProfileAndEntries(); // Pastikan await di sini juga

    if (_selectedIndex == 1) { // Jika tab Statistik dipilih
      // _statisticsScreenKey.currentState?.refreshData(); // Hapus panggilan ini
    }
  }

  void _goToPreviousDay() async { // Ubah menjadi async
    setState(() {
      _currentDate = _currentDate.subtract(const Duration(days: 1));
    });
    await _loadUserProfileAndEntries(); // Pastikan await
  }

  void _goToNextDay() async { // Ubah menjadi async
    setState(() {
      _currentDate = _currentDate.add(const Duration(days: 1));
    });
    await _loadUserProfileAndEntries(); // Pastikan await
  }

  void _addFood(String foodName, int calories, String mealType, double? protein, double? fat, double? carb, String? imagePath) async {
    setState(() {
      _foodEntries.add(FoodEntry(foodName: foodName, calories: calories, mealType: mealType, protein: protein, fat: fat, carb: carb, imagePath: imagePath));
      _caloriesConsumed = _foodEntries.fold(0, (sum, entry) => sum + entry.calories);
      _proteinConsumed = _foodEntries.fold(0.0, (sum, entry) => sum + (entry.protein ?? 0.0));
      _fatConsumed = _foodEntries.fold(0.0, (sum, entry) => sum + (entry.fat ?? 0.0));
      _carbConsumed = _foodEntries.fold(0.0, (sum, entry) => sum + (entry.carb ?? 0.0));
    });
    await _saveEntries();
  }

  void _addActivity(String activityName, int caloriesBurned) async { // Ubah menjadi async
    setState(() {
      _activityEntries.add(ActivityEntry(activityName: activityName, caloriesBurned: caloriesBurned));
      _caloriesBurned = _activityEntries.fold(0, (sum, entry) => sum + entry.caloriesBurned);
    });
    await _saveEntries(); // Pastikan await
  }

  void _addWeight(double weight) async { // Ubah menjadi async
    setState(() {
      _weightEntries.add(WeightEntry(weight: weight, date: DateTime.now()));
      // Urutkan berat badan setelah menambah (terbaru di atas)
      _weightEntries.sort((a, b) => b.date.compareTo(a.date));
    });
    await _saveEntries();
    print('Weight entry added and saved: $weight kg');
    print('DashboardScreen: _weightEntries after adding and before _saveEntries: ${_weightEntries.map((e) => e.weight).toList()}'); // Tambahkan log ini
    await _loadUserProfileAndEntries(); // Pastikan await
    print('Attempted to load entries immediately after saving.');
  }

  @override
  Widget build(BuildContext context) {
    final Color darkGreenBg = const Color(0xFF1D362C);
    final Color lightGreenText = const Color(0xFFA2F46E);
    final Color darkText = const Color(0xFF112D21);
    final Color greyText = Colors.grey[600]!;

    final int remainingCalories = _dailyCalories - _caloriesConsumed + _caloriesBurned;
    final double calorieProgress = _dailyCalories > 0 ? (remainingCalories / _dailyCalories).clamp(0.0, 1.0) : 0.0;

    return Scaffold(
      backgroundColor: darkGreenBg,
      appBar: AppBar(
        backgroundColor: darkGreenBg,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          _selectedIndex == 0 ? 'Dashboard' : (_selectedIndex == 1 ? 'Statistik Berat Badan' : 'Profil Pengguna'), // Judul dinamis
          style: TextStyle(color: lightGreenText, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        actions: [
          if (_selectedIndex == 1) // Hanya tampilkan tombol refresh di tab Statistik
            IconButton(
              icon: Icon(Icons.refresh, color: lightGreenText),
              onPressed: () {
                // _statisticsScreenKey.currentState?.refreshData(); // Hapus panggilan ini
              },
            ),
          IconButton(
            icon: Icon(Icons.settings, color: lightGreenText),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
          ),
        ],
        centerTitle: true, // Pusatkan judul
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Tanggal dan Navigasi Hari (Dipindahkan ke dalam body)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back_ios, color: lightGreenText),
                      onPressed: _goToPreviousDay,
                    ),
                    Expanded(
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              DateFormat('dd MMMM yyyy', 'id_ID').format(_currentDate), // Langsung format tanggal
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: lightGreenText,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.arrow_forward_ios, color: lightGreenText),
                      onPressed: _goToNextDay,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Masuk Kalori
                      Column(
                        children: [
                          Text(
                            'Masuk',
                            style: TextStyle(color: lightGreenText.withOpacity(0.8), fontSize: 16),
                          ),
                          Text(
                            '$_caloriesConsumed',
                            style: TextStyle(color: lightGreenText, fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'kalori',
                            style: TextStyle(color: lightGreenText.withOpacity(0.8), fontSize: 14),
                          ),
                        ],
                      ),
                      const SizedBox(width: 20), // Spasi antara teks dan lingkaran
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 200, // Ukuran lingkaran progres
                            height: 200,
                            child: CircularProgressIndicator(
                              value: calorieProgress, // Gunakan progres kalori
                              strokeWidth: 10, // Ketebalan lingkaran
                              valueColor: AlwaysStoppedAnimation<Color>(lightGreenText), // Warna progres
                              backgroundColor: lightGreenText.withOpacity(0.3), // Warna background lingkaran
                            ),
                          ),
                          Text(
                            '$remainingCalories', // Kalori sisa di tengah lingkaran
                            style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: lightGreenText),
                          ),
                        ],
                      ),
                      const SizedBox(width: 20), // Spasi antara lingkaran dan teks
                      // Dibakar Kalori
                      Column(
                        children: [
                          Text(
                            'Dibakar',
                            style: TextStyle(color: lightGreenText.withOpacity(0.8), fontSize: 16),
                          ),
                          Text(
                            '$_caloriesBurned',
                            style: TextStyle(color: lightGreenText, fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Kalori',
                            style: TextStyle(color: lightGreenText.withOpacity(0.8), fontSize: 14),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color: lightGreenText.withOpacity(0.5),
                        thickness: 1,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        'Kalori Masuk',
                        style: TextStyle(color: lightGreenText, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        color: lightGreenText.withOpacity(0.5),
                        thickness: 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildMacronutrientCircle('Karbo', _carbConsumed.round(), _carbGrams, lightGreenText, darkGreenBg),
                    _buildMacronutrientCircle('Lemak', _fatConsumed.round(), _fatGrams, lightGreenText, darkGreenBg),
                    _buildMacronutrientCircle('Protein', _proteinConsumed.round(), _proteinGrams, lightGreenText, darkGreenBg),
                  ],
                ),
                const SizedBox(height: 20),
                Card(
                  color: darkGreenBg, // Warna latar belakang kartu sesuai tema
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15), // Sudut membulat
                    side: BorderSide(color: lightGreenText, width: 2), // Border
                  ),
                  child: InkWell(
                    onTap: () {
                      // Navigasi ke AddFoodScreen dan tunggu hasilnya
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddFoodScreen(
                            onFoodAdded: (foodName, calories, mealType, protein, fat, carb, imagePath) {
                              _addFood(foodName, calories, mealType, protein, fat, carb, imagePath);
                            },
                          ),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(15),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Tambah Makanan',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: lightGreenText),
                          ),
                          Icon(Icons.add_circle_outline, color: lightGreenText, size: 28),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20), // Spasi antar tombol tambah
                // Tombol Tambah Aktivitas
                Card(
                  color: darkGreenBg,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                    side: BorderSide(color: lightGreenText, width: 2),
                  ),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddActivityScreen(
                            onActivityAdded: (activityName, caloriesBurned) {
                              _addActivity(activityName, caloriesBurned);
                            },
                          ),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(15),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Tambah Aktivitas',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: lightGreenText),
                          ),
                          Icon(Icons.directions_run, color: lightGreenText, size: 28), // Ikon lari/aktivitas
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20), // Spasi antar tombol tambah
                // Tombol Catat Berat Badan
                Card(
                  color: darkGreenBg,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                    side: BorderSide(color: lightGreenText, width: 2),
                  ),
                  child: InkWell(
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddWeightScreen(
                            onWeightAdded: (weight) {
                              _addWeight(weight);
                            },
                          ),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(15),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Catat Berat Badan',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: lightGreenText),
                          ),
                          Icon(Icons.monitor_weight, color: lightGreenText, size: 28), // Ikon berat badan
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                // Bagian untuk menampilkan daftar makanan
                _buildFoodEntriesList(),
                const SizedBox(height: 40), // Spasi antara daftar makanan dan aktivitas
                // Bagian untuk menampilkan daftar aktivitas
                _buildActivityEntriesList(),
              ],
            ),
          ),
          StatisticsScreen(key: _statisticsScreenKey, weightEntries: _weightEntries),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Statistik',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: lightGreenText,
        unselectedItemColor: lightGreenText.withOpacity(0.6),
        backgroundColor: darkGreenBg, // Warna background bottom nav
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildMacronutrientCircle(String label, int current, int total, Color textColor, Color bgColor) {
    double progress = total > 0 ? current / total : 0.0;
    return Column(
      children: [
        Stack(
          alignment: Alignment.center, // Pusatkan konten di dalam Stack
          children: [
            SizedBox(
              width: 80, // Ukuran lingkaran
              height: 80,
              child: CircularProgressIndicator(
                value: progress,
                strokeWidth: 5,
                valueColor: AlwaysStoppedAnimation<Color>(textColor), // Warna progres
                backgroundColor: textColor.withOpacity(0.3), // Warna background lingkaran
              ),
            ),
            Text(
              '${current}g', // Tampilkan nilai 'current' di tengah lingkaran
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor), // Sesuaikan gaya teks
            ),
          ],
        ),
        const SizedBox(height: 5),
        Text(
          '$current / ${total}g',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 14, color: textColor.withOpacity(0.8)),
        ),
      ],
    );
  }

  Widget _buildFoodEntriesList() {
    // Kelompokkan makanan berdasarkan jenis makanan
    Map<String, List<FoodEntry>> groupedEntries = {};
    for (var entry in _foodEntries) {
      if (!groupedEntries.containsKey(entry.mealType)) {
        groupedEntries[entry.mealType] = [];
      }
      groupedEntries[entry.mealType]!.add(entry);
    }

    // Urutan jenis makanan
    final List<String> mealOrder = ['Sarapan', 'Makan Siang', 'Makan Malam', 'Cemilan'];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: mealOrder.map((mealType) {
        List<FoodEntry> entries = groupedEntries[mealType] ?? [];
        if (entries.isEmpty) {
          return const SizedBox.shrink(); // Jangan tampilkan jika tidak ada entri
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Text(
              mealType,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xFFA2F46E)),
            ),
            const SizedBox(height: 10),
            ...entries.map((entry) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    entry.foodName,
                    style: TextStyle(fontSize: 18, color: const Color(0xFFA2F46E).withOpacity(0.9)),
                  ),
                  Text(
                    '${entry.calories} kcal',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFFA2F46E)),
                  ),
                ],
              ),
            )),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildActivityEntriesList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Aktivitas Hari Ini',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xFFA2F46E)),
        ),
        const SizedBox(height: 10),
        if (_activityEntries.isEmpty)
          Text(
            'Belum ada aktivitas yang dicatat.',
            style: TextStyle(fontSize: 16, color: const Color(0xFFA2F46E).withOpacity(0.7)),
          ) 
        else
          ..._activityEntries.map((entry) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  entry.activityName,
                  style: TextStyle(fontSize: 18, color: const Color(0xFFA2F46E).withOpacity(0.9)),
                ),
                Text(
                  '${entry.caloriesBurned} kcal',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFFA2F46E)),
                ),
              ],
            ),
          )),
      ],
    );
  }

  String _getMonthName(int month) {
    switch (month) {
      case 1: return 'Jan';
      case 2: return 'Feb';
      case 3: return 'Mar';
      case 4: return 'Apr';
      case 5: return 'Mei';
      case 6: return 'Jun';
      case 7: return 'Jul';
      case 8: return 'Agu';
      case 9: return 'Sep';
      case 10: return 'Okt';
      case 11: return 'Nov';
      case 12: return 'Des';
      default: return '';
    }
  }
} 