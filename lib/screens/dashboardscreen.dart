import 'package:flutter/material.dart';
import 'package:flutter_application_rpl_final/screens/statisticsscreen.dart';
import 'package:flutter_application_rpl_final/screens/profilescreen.dart';
import 'package:flutter_application_rpl_final/screens/addfoodscreen.dart';
import 'package:flutter_application_rpl_final/screens/addactivityscreen.dart';
import 'package:flutter_application_rpl_final/screens/settingsscreen.dart';
import 'package:flutter_application_rpl_final/screens/addcustomfoodscreen.dart';
import 'package:flutter_application_rpl_final/utils/logger.dart';
import 'package:flutter_application_rpl_final/utils/error_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter_application_rpl_final/widgets/custom_page_route.dart';

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

  ActivityEntry({required this.activityName, required this.caloriesBurned});

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

  WeightEntry({required this.weight, required this.date});

  Map<String, dynamic> toJson() => {
    'weight': weight,
    'date': date.toIso8601String(), // Simpan sebagai string ISO 8601
  };

  factory WeightEntry.fromJson(Map<String, dynamic> json) {
    return WeightEntry(
      weight: json['weight'] as double,
      date: DateTime.parse(
        json['date'] as String,
      ), // Parse dari string ISO 8601
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

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
  final GlobalKey<ProfileScreenState> _profileScreenKey = GlobalKey();

  // Flag untuk mencegah multiple navigation
  bool _isNavigating = false;

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
  Future<void> _loadUserProfileAndEntries() async {
    // Ubah nama fungsi
    AppLogger.debug('Loading all entries and user profile...');
    try {
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
        AppLogger.debug('User profile data loaded: $_dailyCalories kcal');
      }

      // Muat entri makanan
      final List<String>? foodEntriesJson = prefs.getStringList(
        '${dateKey}_food',
      );
      setState(() {
        _foodEntries =
            foodEntriesJson
                ?.map((entryJson) => FoodEntry.fromJson(jsonDecode(entryJson)))
                .toList() ??
            [];
        _caloriesConsumed = _foodEntries.fold(
          0,
          (sum, entry) => sum + (entry.calories > 0 ? entry.calories : 0),
        );
        _proteinConsumed = _foodEntries.fold(
          0.0,
          (sum, entry) =>
              sum + ((entry.protein ?? 0.0) > 0 ? (entry.protein ?? 0.0) : 0.0),
        );
        _fatConsumed = _foodEntries.fold(
          0.0,
          (sum, entry) =>
              sum + ((entry.fat ?? 0.0) > 0 ? (entry.fat ?? 0.0) : 0.0),
        );
        _carbConsumed = _foodEntries.fold(
          0.0,
          (sum, entry) =>
              sum + ((entry.carb ?? 0.0) > 0 ? (entry.carb ?? 0.0) : 0.0),
        );
        AppLogger.debug('Food entries loaded: ${_foodEntries.length}');
      });

      // Muat entri aktivitas
      final List<String>? activityEntriesJson = prefs.getStringList(
        '${dateKey}_activity',
      );
      setState(() {
        _activityEntries =
            activityEntriesJson
                ?.map(
                  (entryJson) => ActivityEntry.fromJson(jsonDecode(entryJson)),
                )
                .toList() ??
            [];
        _caloriesBurned = _activityEntries.fold(
          0,
          (sum, entry) => sum + entry.caloriesBurned,
        );
        AppLogger.debug('Activity entries loaded: ${_activityEntries.length}');
      });

      // Muat entri berat badan (tidak terkait dengan tanggal harian, jadi kunci terpisah atau semua riwayat)
      // Untuk saat ini, kita akan menyimpan semua riwayat berat badan dalam satu kunci terpisah
      final List<String>? weightEntriesJson = prefs.getStringList(
        'all_weight_entries',
      );
      AppLogger.debug(
        'Raw weight entries JSON loaded: ${weightEntriesJson?.length ?? 0} entries',
      );
      setState(() {
        _weightEntries =
            weightEntriesJson
                ?.map(
                  (entryJson) => WeightEntry.fromJson(jsonDecode(entryJson)),
                )
                .toList() ??
            [];
        // Urutkan berat badan berdasarkan tanggal (terbaru di atas)
        _weightEntries.sort((a, b) => b.date.compareTo(a.date));
        AppLogger.debug('Weight entries loaded: ${_weightEntries.length}');
      });
    } catch (e, stackTrace) {
      if (mounted) {
        ErrorHandler.handleError(
          context,
          e,
          stackTrace,
          customMessage: 'Gagal memuat data entri',
        );
      } else {
        AppLogger.error(
          'Failed to load entries (widget not mounted)',
          e,
          stackTrace,
        );
      }
    }
  }

  // Fungsi untuk menyimpan entri makanan, aktivitas, dan berat badan
  Future<void> _saveEntries() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dateKey = _getDateKey(_currentDate);

      // Simpan entri makanan
      final List<String> foodEntriesJson = _foodEntries
          .map((entry) => jsonEncode(entry.toJson()))
          .toList();
      await prefs.setStringList('${dateKey}_food', foodEntriesJson);
      AppLogger.debug('Food entries saved: ${_foodEntries.length} entries');

      // Simpan entri aktivitas
      final List<String> activityEntriesJson = _activityEntries
          .map((entry) => jsonEncode(entry.toJson()))
          .toList();
      await prefs.setStringList('${dateKey}_activity', activityEntriesJson);
      AppLogger.debug(
        'Activity entries saved: ${_activityEntries.length} entries',
      );

      // Simpan entri berat badan
      final List<String> weightEntriesJson = _weightEntries
          .map((entry) => jsonEncode(entry.toJson()))
          .toList();
      await prefs.setStringList('all_weight_entries', weightEntriesJson);
      AppLogger.debug('Weight entries saved: ${_weightEntries.length} entries');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to save entries', e, stackTrace);
      if (mounted) {
        ErrorHandler.handleError(
          context,
          e,
          stackTrace,
          customMessage: 'Gagal menyimpan data',
        );
      }
      rethrow;
    }
  }

  void _onItemTapped(int index) async {
    // Jadikan async
    setState(() {
      _selectedIndex = index;
    });
    // Pastikan data dashboard dimuat ulang saat berpindah tab
    await _loadUserProfileAndEntries(); // Pastikan await di sini juga

    if (_selectedIndex == 2) {
      _profileScreenKey.currentState?.refreshProfile();
    }
  }

  void _goToPreviousDay() async {
    // Ubah menjadi async
    setState(() {
      _currentDate = _currentDate.subtract(const Duration(days: 1));
    });
    await _loadUserProfileAndEntries(); // Pastikan await
  }

  void _goToNextDay() async {
    // Ubah menjadi async
    setState(() {
      _currentDate = _currentDate.add(const Duration(days: 1));
    });
    await _loadUserProfileAndEntries(); // Pastikan await
  }

  void _addFood(
    String foodName,
    int calories,
    String mealType,
    double? protein,
    double? fat,
    double? carb,
    String? imagePath,
  ) async {
    setState(() {
      _foodEntries.add(
        FoodEntry(
          foodName: foodName,
          calories: calories,
          mealType: mealType,
          protein: protein,
          fat: fat,
          carb: carb,
          imagePath: imagePath,
        ),
      );
      _caloriesConsumed = _foodEntries.fold(
        0,
        (sum, entry) => sum + (entry.calories > 0 ? entry.calories : 0),
      );
      _proteinConsumed = _foodEntries.fold(
        0.0,
        (sum, entry) =>
            sum + ((entry.protein ?? 0.0) > 0 ? (entry.protein ?? 0.0) : 0.0),
      );
      _fatConsumed = _foodEntries.fold(
        0.0,
        (sum, entry) =>
            sum + ((entry.fat ?? 0.0) > 0 ? (entry.fat ?? 0.0) : 0.0),
      );
      _carbConsumed = _foodEntries.fold(
        0.0,
        (sum, entry) =>
            sum + ((entry.carb ?? 0.0) > 0 ? (entry.carb ?? 0.0) : 0.0),
      );
    });
    await _saveEntries();
  }

  void _addActivity(String activityName, int caloriesBurned) async {
    // Ubah menjadi async
    setState(() {
      _activityEntries.add(
        ActivityEntry(
          activityName: activityName,
          caloriesBurned: caloriesBurned,
        ),
      );
      _caloriesBurned = _activityEntries.fold(
        0,
        (sum, entry) => sum + entry.caloriesBurned,
      );
    });
    await _saveEntries(); // Pastikan await
  }

  void _updateFood(int index, FoodEntry updatedFood) async {
    setState(() {
      _foodEntries[index] = updatedFood;
      // Recalculate consumed values
      _caloriesConsumed = _foodEntries.fold(
        0,
        (sum, entry) => sum + (entry.calories > 0 ? entry.calories : 0),
      );
      _proteinConsumed = _foodEntries.fold(
        0.0,
        (sum, entry) =>
            sum + ((entry.protein ?? 0.0) > 0 ? (entry.protein ?? 0.0) : 0.0),
      );
      _fatConsumed = _foodEntries.fold(
        0.0,
        (sum, entry) =>
            sum + ((entry.fat ?? 0.0) > 0 ? (entry.fat ?? 0.0) : 0.0),
      );
      _carbConsumed = _foodEntries.fold(
        0.0,
        (sum, entry) =>
            sum + ((entry.carb ?? 0.0) > 0 ? (entry.carb ?? 0.0) : 0.0),
      );
    });
    await _saveEntries();
  }

  void _removeFood(FoodEntry entryToRemove) async {
    setState(() {
      _foodEntries.removeWhere(
        (entry) =>
            entry.foodName == entryToRemove.foodName &&
            entry.calories == entryToRemove.calories &&
            entry.mealType == entryToRemove.mealType &&
            entry.protein == entryToRemove.protein &&
            entry.fat == entryToRemove.fat &&
            entry.carb == entryToRemove.carb,
      );
      // Recalculate consumed values
      _caloriesConsumed = _foodEntries.fold(
        0,
        (sum, entry) => sum + (entry.calories > 0 ? entry.calories : 0),
      );
      _proteinConsumed = _foodEntries.fold(
        0.0,
        (sum, entry) =>
            sum + ((entry.protein ?? 0.0) > 0 ? (entry.protein ?? 0.0) : 0.0),
      );
      _fatConsumed = _foodEntries.fold(
        0.0,
        (sum, entry) =>
            sum + ((entry.fat ?? 0.0) > 0 ? (entry.fat ?? 0.0) : 0.0),
      );
      _carbConsumed = _foodEntries.fold(
        0.0,
        (sum, entry) =>
            sum + ((entry.carb ?? 0.0) > 0 ? (entry.carb ?? 0.0) : 0.0),
      );
    });
    await _saveEntries();
  }

  void _removeActivity(ActivityEntry entryToRemove) async {
    setState(() {
      _activityEntries.removeWhere(
        (entry) =>
            entry.activityName == entryToRemove.activityName &&
            entry.caloriesBurned == entryToRemove.caloriesBurned,
      );
      // Recalculate burned calories
      _caloriesBurned = _activityEntries.fold(
        0,
        (sum, entry) => sum + entry.caloriesBurned,
      );
    });
    await _saveEntries();
  }

  // Helper methods - defined before build() to avoid "referenced before declaration" errors
  Widget _buildMacronutrientCircle(
    String label,
    int current,
    int total,
    Color textColor,
    Color bgColor,
  ) {
    // Pastikan current tidak minus
    final int safeCurrent = current < 0 ? 0 : current;

    // Cek apakah melewati batas
    final bool isOverLimit = safeCurrent > total && total > 0;

    // Warna untuk lingkaran dan teks (merah jika melewati batas)
    final Color displayColor = isOverLimit
        ? const Color(0xFFB22222) // Merah seperti kalori harian
        : textColor;

    // Progress value (clamp antara 0 dan 1, atau lebih dari 1 jika melewati batas)
    double progress = total > 0 ? (safeCurrent / total).clamp(0.0, 1.0) : 0.0;

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
                valueColor: AlwaysStoppedAnimation<Color>(
                  displayColor,
                ), // Warna progres (merah jika melewati batas)
                backgroundColor: displayColor.withOpacity(
                  0.3,
                ), // Warna background lingkaran
              ),
            ),
            Text(
              '${safeCurrent}g', // Tampilkan nilai 'current' di tengah lingkaran
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: displayColor,
              ), // Warna teks (merah jika melewati batas)
            ),
          ],
        ),
        const SizedBox(height: 5),
        Text(
          '$safeCurrent / ${total}g',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: displayColor,
          ), // Warna teks (merah jika melewati batas)
        ),
        Text(
          label,
          style: TextStyle(fontSize: 14, color: displayColor.withOpacity(0.8)),
        ),
      ],
    );
  }

  Widget _buildFoodEntriesList() {
    final Color darkGreenBg = const Color(0xFF1D362C);
    final Color lightGreenText = const Color(0xFFA2F46E);

    // Kelompokkan makanan berdasarkan jenis makanan
    Map<String, List<FoodEntry>> groupedEntries = {};
    for (var entry in _foodEntries) {
      if (!groupedEntries.containsKey(entry.mealType)) {
        groupedEntries[entry.mealType] = [];
      }
      groupedEntries[entry.mealType]!.add(entry);
    }

    // Urutan jenis makanan
    final List<String> mealOrder = [
      'Sarapan',
      'Makan Siang',
      'Makan Malam',
      'Cemilan',
    ];

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
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: const Color(0xFFA2F46E),
              ),
            ),
            const SizedBox(height: 10),
            ...entries.asMap().entries.map((entryMap) {
              final entry = entryMap.value;
              final index = entryMap.key;
              // Cari index di _foodEntries (bukan di groupedEntries)
              final int globalIndex = _foodEntries.indexWhere(
                (e) =>
                    e.foodName == entry.foodName &&
                    e.calories == entry.calories &&
                    e.mealType == entry.mealType &&
                    e.protein == entry.protein &&
                    e.fat == entry.fat &&
                    e.carb == entry.carb,
              );
              return Dismissible(
                key: Key(
                  'food_${mealType}_${index}_${entry.foodName}_${entry.calories}',
                ),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20.0),
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.delete,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                confirmDismiss: (direction) async {
                  final bool? confirmed = await showDialog<bool>(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        backgroundColor: darkGreenBg,
                        title: Text(
                          'Hapus Makanan',
                          style: TextStyle(color: lightGreenText),
                        ),
                        content: Text(
                          'Apakah Anda yakin ingin menghapus "${entry.foodName}"?',
                          style: TextStyle(
                            color: lightGreenText.withOpacity(0.8),
                          ),
                        ),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: Text(
                              'Batal',
                              style: TextStyle(
                                color: lightGreenText.withOpacity(0.7),
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: Text(
                              'Hapus',
                              style: TextStyle(color: Colors.redAccent),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                  return confirmed ?? false;
                },
                onDismissed: (direction) {
                  _removeFood(entry);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${entry.foodName} telah dihapus'),
                      backgroundColor: const Color(0xFFA2F46E),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                child: InkWell(
                  onTap: () async {
                    if (_isNavigating) return;
                    _isNavigating = true;
                    if (!mounted) {
                      _isNavigating = false;
                      return;
                    }
                    // Navigasi ke halaman edit
                    await Navigator.push(
                      context,
                      CustomPageRoute(
                        child: AddCustomFoodScreen(
                          existingFood: entry,
                          isEditMode: true,
                          onFoodAdded:
                              (
                                foodName,
                                calories,
                                mealType,
                                protein,
                                fat,
                                carb,
                                imagePath,
                              ) {
                                // Update makanan yang sudah ada
                                final updatedFood = FoodEntry(
                                  foodName: foodName,
                                  calories: calories,
                                  mealType: mealType,
                                  protein: protein,
                                  fat: fat,
                                  carb: carb,
                                  imagePath: imagePath,
                                );
                                if (globalIndex >= 0 &&
                                    globalIndex < _foodEntries.length) {
                                  _updateFood(globalIndex, updatedFood);
                                }
                              },
                        ),
                        backgroundColor: darkGreenBg,
                      ),
                    );
                    _isNavigating = false;
                    // Reload entries setelah edit
                    await _loadUserProfileAndEntries();
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          entry.foodName,
                          style: TextStyle(
                            fontSize: 18,
                            color: const Color(0xFFA2F46E).withOpacity(0.9),
                          ),
                        ),
                        Text(
                          '${entry.calories} kcal',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFA2F46E),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildActivityEntriesList() {
    final Color darkGreenBg = const Color(0xFF1D362C);
    final Color lightGreenText = const Color(0xFFA2F46E);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Aktivitas Hari Ini',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: const Color(0xFFA2F46E),
          ),
        ),
        const SizedBox(height: 10),
        if (_activityEntries.isEmpty)
          Text(
            'Belum ada aktivitas yang dicatat.',
            style: TextStyle(
              fontSize: 16,
              color: const Color(0xFFA2F46E).withOpacity(0.7),
            ),
          )
        else
          ..._activityEntries.asMap().entries.map((entryMap) {
            final entry = entryMap.value;
            final index = entryMap.key;
            return Dismissible(
              key: Key(
                'activity_${index}_${entry.activityName}_${entry.caloriesBurned}',
              ),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20.0),
                decoration: BoxDecoration(
                  color: Colors.redAccent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.delete, color: Colors.white, size: 30),
              ),
              confirmDismiss: (direction) async {
                final bool? confirmed = await showDialog<bool>(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      backgroundColor: darkGreenBg,
                      title: Text(
                        'Hapus Aktivitas',
                        style: TextStyle(color: lightGreenText),
                      ),
                      content: Text(
                        'Apakah Anda yakin ingin menghapus "${entry.activityName}"?',
                        style: TextStyle(
                          color: lightGreenText.withOpacity(0.8),
                        ),
                      ),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: Text(
                            'Batal',
                            style: TextStyle(
                              color: lightGreenText.withOpacity(0.7),
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: Text(
                            'Hapus',
                            style: TextStyle(color: Colors.redAccent),
                          ),
                        ),
                      ],
                    );
                  },
                );
                return confirmed ?? false;
              },
              onDismissed: (direction) {
                _removeActivity(entry);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${entry.activityName} telah dihapus'),
                    backgroundColor: const Color(0xFFA2F46E),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      entry.activityName,
                      style: TextStyle(
                        fontSize: 18,
                        color: const Color(0xFFA2F46E).withOpacity(0.9),
                      ),
                    ),
                    Text(
                      '${entry.caloriesBurned} kcal',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFA2F46E),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color darkGreenBg = const Color(0xFF1D362C);
    final Color lightGreenText = const Color(0xFFA2F46E);

    final int rawRemainingCalories =
        _dailyCalories - _caloriesConsumed + _caloriesBurned;
    final bool isOverLimit = rawRemainingCalories < 0;
    final int displayedRemainingCalories = rawRemainingCalories;

    final double progressValue;
    if (_dailyCalories <= 0) {
      progressValue = 0.0;
    } else if (isOverLimit) {
      progressValue = (-rawRemainingCalories / _dailyCalories).clamp(0.0, 1.0);
    } else {
      progressValue = (rawRemainingCalories / _dailyCalories).clamp(0.0, 1.0);
    }

    final Color statusColor = isOverLimit
        ? const Color(0xFFB22222)
        : lightGreenText;
    final String statusLabel = isOverLimit ? 'Kalori Berlebih' : 'sisa kalori';

    return Scaffold(
      backgroundColor: darkGreenBg,
      appBar: AppBar(
        backgroundColor: darkGreenBg,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          _selectedIndex == 0
              ? 'Dashboard'
              : (_selectedIndex == 1
                    ? 'Statistik Berat Badan'
                    : 'Profil Pengguna'), // Judul dinamis
          style: TextStyle(
            color: lightGreenText,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: lightGreenText),
            onPressed: () async {
              if (_isNavigating) return;
              _isNavigating = true;
              if (mounted) {
                Navigator.push(
                  context,
                  CustomPageRoute(
                    child: const SettingsScreen(),
                    backgroundColor: darkGreenBg,
                  ),
                ).then((_) {
                  _isNavigating = false;
                });
              } else {
                _isNavigating = false;
              }
            },
          ),
        ],
        centerTitle: true, // Pusatkan judul
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 16.0,
                right: 16.0,
                top: 16.0,
                bottom: 16.0 + MediaQuery.of(context).padding.bottom,
              ),
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
                                DateFormat('dd MMMM yyyy', 'id_ID').format(
                                  _currentDate,
                                ), // Langsung format tanggal
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
                        icon: Icon(
                          Icons.arrow_forward_ios,
                          color: lightGreenText,
                        ),
                        onPressed: _goToNextDay,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Gunakan LayoutBuilder untuk membuat layout responsif
                  LayoutBuilder(
                    builder: (context, constraints) {
                      // Hitung ukuran layar
                      final screenWidth = MediaQuery.of(context).size.width;

                      // Ukuran circular progress responsif (maksimal 220, minimal 150)
                      final double circleSize = (screenWidth * 0.5).clamp(
                        150.0,
                        220.0,
                      );
                      final double innerCircleSize = (circleSize * 0.9).clamp(
                        130.0,
                        200.0,
                      );
                      final double fontSize = (circleSize * 0.22).clamp(
                        32.0,
                        48.0,
                      );
                      final double labelFontSize = (circleSize * 0.07).clamp(
                        12.0,
                        16.0,
                      );
                      final double sideFontSize = (circleSize * 0.11).clamp(
                        18.0,
                        24.0,
                      );

                      return Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Masuk Kalori
                            Flexible(
                              child: Column(
                                children: [
                                  Text(
                                    'Masuk',
                                    style: TextStyle(
                                      color: lightGreenText.withOpacity(0.8),
                                      fontSize: labelFontSize,
                                    ),
                                  ),
                                  Text(
                                    '$_caloriesConsumed',
                                    style: TextStyle(
                                      color: lightGreenText,
                                      fontSize: sideFontSize,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'kalori',
                                    style: TextStyle(
                                      color: lightGreenText.withOpacity(0.8),
                                      fontSize: labelFontSize * 0.85,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              width: screenWidth * 0.05,
                            ), // Spasi responsif antara teks dan lingkaran
                            SizedBox(
                              width: circleSize,
                              height: circleSize,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Container(
                                    width: innerCircleSize,
                                    height: innerCircleSize,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: statusColor.withOpacity(0.05),
                                      border: Border.all(
                                        color: statusColor.withOpacity(0.2),
                                        width: (circleSize * 0.027).clamp(
                                          4.0,
                                          6.0,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: circleSize,
                                    height: circleSize,
                                    child: TweenAnimationBuilder<double>(
                                      tween: Tween<double>(
                                        begin: 0.0,
                                        end: progressValue,
                                      ),
                                      duration: const Duration(
                                        milliseconds: 500,
                                      ),
                                      curve: Curves.easeOut,
                                      builder: (context, value, _) {
                                        return CircularProgressIndicator(
                                          value: value,
                                          strokeWidth: (circleSize * 0.055)
                                              .clamp(8.0, 12.0),
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                statusColor,
                                              ),
                                          backgroundColor: statusColor
                                              .withOpacity(0.15),
                                        );
                                      },
                                    ),
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                          '$displayedRemainingCalories',
                                          style: TextStyle(
                                            fontSize: fontSize,
                                            fontWeight: FontWeight.bold,
                                            color: statusColor,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                          statusLabel,
                                          style: TextStyle(
                                            fontSize: labelFontSize,
                                            color: statusColor.withOpacity(0.8),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              width: screenWidth * 0.05,
                            ), // Spasi responsif antara lingkaran dan teks
                            // Dibakar Kalori
                            Flexible(
                              child: Column(
                                children: [
                                  Text(
                                    'Dibakar',
                                    style: TextStyle(
                                      color: lightGreenText.withOpacity(0.8),
                                      fontSize: labelFontSize,
                                    ),
                                  ),
                                  Text(
                                    '$_caloriesBurned',
                                    style: TextStyle(
                                      color: lightGreenText,
                                      fontSize: sideFontSize,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'Kalori',
                                    style: TextStyle(
                                      color: lightGreenText.withOpacity(0.8),
                                      fontSize: labelFontSize * 0.85,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
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
                          style: TextStyle(
                            color: lightGreenText,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
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
                      _buildMacronutrientCircle(
                        'Karbo',
                        _carbConsumed.round(),
                        _carbGrams,
                        lightGreenText,
                        darkGreenBg,
                      ),
                      _buildMacronutrientCircle(
                        'Lemak',
                        _fatConsumed.round(),
                        _fatGrams,
                        lightGreenText,
                        darkGreenBg,
                      ),
                      _buildMacronutrientCircle(
                        'Protein',
                        _proteinConsumed.round(),
                        _proteinGrams,
                        lightGreenText,
                        darkGreenBg,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Card(
                    color:
                        darkGreenBg, // Warna latar belakang kartu sesuai tema
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15), // Sudut membulat
                      side: BorderSide(
                        color: lightGreenText,
                        width: 2,
                      ), // Border
                    ),
                    child: InkWell(
                      onTap: () async {
                        if (_isNavigating) return;
                        _isNavigating = true;
                        if (!mounted) {
                          _isNavigating = false;
                          return;
                        }
                        // Navigasi ke AddFoodScreen dan tunggu hasilnya
                        Navigator.push(
                          context,
                          CustomPageRoute(
                            child: AddFoodScreen(
                              onFoodAdded:
                                  (
                                    foodName,
                                    calories,
                                    mealType,
                                    protein,
                                    fat,
                                    carb,
                                    imagePath,
                                  ) {
                                    _addFood(
                                      foodName,
                                      calories,
                                      mealType,
                                      protein,
                                      fat,
                                      carb,
                                      imagePath,
                                    );
                                  },
                            ),
                            backgroundColor: darkGreenBg,
                          ),
                        ).then((_) {
                          _isNavigating = false;
                        });
                      },
                      borderRadius: BorderRadius.circular(15),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 20.0,
                          horizontal: 16.0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Tambah Makanan',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: lightGreenText,
                              ),
                            ),
                            Icon(
                              Icons.add_circle_outline,
                              color: lightGreenText,
                              size: 28,
                            ),
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
                      onTap: () async {
                        if (_isNavigating) return;
                        _isNavigating = true;
                        if (!mounted) {
                          _isNavigating = false;
                          return;
                        }
                        Navigator.push(
                          context,
                          CustomPageRoute(
                            child: AddActivityScreen(
                              onActivityAdded: (activityName, caloriesBurned) {
                                _addActivity(activityName, caloriesBurned);
                              },
                            ),
                            backgroundColor: darkGreenBg,
                          ),
                        ).then((_) {
                          _isNavigating = false;
                        });
                      },
                      borderRadius: BorderRadius.circular(15),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 20.0,
                          horizontal: 16.0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Tambah Aktivitas',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: lightGreenText,
                              ),
                            ),
                            Icon(
                              Icons.directions_run,
                              color: lightGreenText,
                              size: 28,
                            ), // Ikon lari/aktivitas
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Bagian untuk menampilkan daftar makanan
                  _buildFoodEntriesList(),
                  const SizedBox(
                    height: 40,
                  ), // Spasi antara daftar makanan dan aktivitas
                  // Bagian untuk menampilkan daftar aktivitas
                  _buildActivityEntriesList(),
                ],
              ),
            ),
          ),
          StatisticsScreen(
            key: _statisticsScreenKey,
            weightEntries: _weightEntries,
          ),
          ProfileScreen(key: _profileScreenKey),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Statistik',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: lightGreenText,
        unselectedItemColor: lightGreenText.withOpacity(0.6),
        backgroundColor: darkGreenBg, // Warna background bottom nav
        onTap: _onItemTapped,
      ),
    );
  }
}
