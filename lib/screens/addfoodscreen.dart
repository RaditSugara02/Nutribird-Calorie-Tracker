import 'package:flutter/material.dart';
import 'package:flutter_application_rpl_final/screens/dashboardscreen.dart'; // Import FoodEntry
import 'package:shared_preferences/shared_preferences.dart'; // Import SharedPreferences
import 'dart:convert'; // Import json
import 'package:flutter_application_rpl_final/screens/addcustomfoodscreen.dart'; // Tambahkan ini
import 'package:flutter_application_rpl_final/screens/fooddetailscreen.dart'; // Tambahkan ini

class AddFoodScreen extends StatefulWidget {
  final Function(String foodName, int calories, String mealType, double? protein, double? fat, double? carb, String? imagePath) onFoodAdded; // Callback baru

  const AddFoodScreen({
    super.key,
    required this.onFoodAdded,
  });

  @override
  State<AddFoodScreen> createState() => _AddFoodScreenState();
}

class _AddFoodScreenState extends State<AddFoodScreen> {
  String? _selectedMealType; // Tambahkan ini untuk jenis makanan

  // Data makanan yang sudah ditetapkan (akan dimuat dan ditambahkan pengguna)
  List<FoodEntry> _allAvailableFoods = [];
  List<FoodEntry> _filteredFoods = [];
  final TextEditingController _searchController = TextEditingController();

  // Data makanan yang sudah ditetapkan secara default
  final List<FoodEntry> _defaultPredefinedFoods = [
    FoodEntry(foodName: 'Nasi Putih', calories: 200, mealType: 'Makan Siang', protein: 4.0, fat: 0.5, carb: 45.0),
    FoodEntry(foodName: 'Ayam Goreng', calories: 300, mealType: 'Makan Malam', protein: 30.0, fat: 20.0, carb: 0.0),
    FoodEntry(foodName: 'Telur Rebus', calories: 80, mealType: 'Sarapan', protein: 7.0, fat: 5.0, carb: 0.5),
    FoodEntry(foodName: 'Pisang', calories: 100, mealType: 'Cemilan', protein: 1.0, fat: 0.3, carb: 27.0),
    FoodEntry(foodName: 'Salad Sayur', calories: 150, mealType: 'Makan Siang', protein: 5.0, fat: 10.0, carb: 15.0),
    FoodEntry(foodName: 'Oatmeal', calories: 180, mealType: 'Sarapan', protein: 6.0, fat: 3.0, carb: 30.0),
    FoodEntry(foodName: 'Tahu Goreng', calories: 120, mealType: 'Makan Siang', protein: 10.0, fat: 8.0, carb: 2.0),
    FoodEntry(foodName: 'Susu Full Cream', calories: 150, mealType: 'Sarapan', protein: 8.0, fat: 8.0, carb: 12.0),
  ];

  @override
  void initState() {
    super.initState();
    _loadAllFoods();
    _searchController.addListener(_filterFoods);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Fungsi untuk memuat semua makanan (pradefinisi + ditambahkan pengguna)
  Future<void> _loadAllFoods() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? userFoodEntriesJson = prefs.getStringList('user_food_entries');

    List<FoodEntry> loadedUserFoods = [];
    if (userFoodEntriesJson != null) {
      loadedUserFoods = userFoodEntriesJson
          .map((entryJson) => FoodEntry.fromJson(jsonDecode(entryJson)))
          .toList();
    }

    setState(() {
      // Gabungkan makanan default dengan makanan yang ditambahkan pengguna
      _allAvailableFoods = [..._defaultPredefinedFoods, ...loadedUserFoods];
      _filterFoods(); // Terapkan filter awal
    });
  }

  // Fungsi untuk menyimpan makanan yang ditambahkan pengguna
  Future<void> _saveUserFoods() async {
    final prefs = await SharedPreferences.getInstance();
    // Filter hanya makanan yang ditambahkan pengguna jika diperlukan, atau simpan semua
    // Untuk saat ini, kita akan menyimpan semua kecuali yang default jika mereka sudah ada
    // Solusi yang lebih baik: simpan makanan user di kunci terpisah, dan gabungkan saat memuat
    final List<String> userFoodEntriesJson = _allAvailableFoods
        .where((food) => !_defaultPredefinedFoods.contains(food)) // Hanya simpan yang bukan default
        .map((entry) => jsonEncode(entry.toJson()))
        .toList();
    await prefs.setStringList('user_food_entries', userFoodEntriesJson);
  }

  void _filterFoods() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredFoods = _allAvailableFoods.where((food) {
        return food.foodName.toLowerCase().contains(query);
      }).toList();
    });
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
          'Tambah Makanan',
          style: TextStyle(color: lightGreenText, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: lightGreenText), // Icon tambah untuk makanan kustom
            onPressed: () async {
              final newFood = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddCustomFoodScreen( // Halaman baru
                    onFoodAdded: (foodName, calories, mealType, protein, fat, carb) {
                      // Callback dari AddCustomFoodScreen
                      return FoodEntry(
                        foodName: foodName,
                        calories: calories,
                        mealType: mealType,
                        protein: protein,
                        fat: fat,
                        carb: carb,
                      );
                    },
                  ),
                ),
              ); // end of await Navigator.push

              if (newFood != null && newFood is FoodEntry) {
                setState(() {
                  // Tambahkan makanan kustom ke daftar yang tersedia
                  _allAvailableFoods.add(newFood);
                  _filterFoods(); // Perbarui daftar yang difilter
                });
                await _saveUserFoods(); // Simpan makanan yang ditambahkan pengguna
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            TextFormField(
              controller: _searchController,
              style: TextStyle(color: lightGreenText),
              decoration: InputDecoration(
                hintText: 'Cari makanan...',
                hintStyle: TextStyle(color: lightGreenText.withOpacity(0.6)),
                prefixIcon: Icon(Icons.search, color: lightGreenText),
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
            ),
            const SizedBox(height: 16),
            Text(
              'Pilih Makanan yang Sudah Ada',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: lightGreenText),
            ),
            const SizedBox(height: 16),
            // Daftar makanan yang sudah ditetapkan (atau difilter)
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _filteredFoods.length,
              itemBuilder: (context, index) {
                final food = _filteredFoods[index];
                return Card(
                  color: darkGreenBg,
                  elevation: 0,
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(color: lightGreenText.withOpacity(0.5), width: 1),
                  ),
                  child: InkWell(
                    onTap: () async {
                      final FoodEntry? adjustedFood = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FoodDetailScreen(food: food), // Navigasi ke FoodDetailScreen
                        ),
                      );

                      if (adjustedFood != null) {
                        widget.onFoodAdded(
                          adjustedFood.foodName,
                          adjustedFood.calories,
                          adjustedFood.mealType,
                          adjustedFood.protein,
                          adjustedFood.fat,
                          adjustedFood.carb,
                          adjustedFood.imagePath,
                        );
                        Navigator.pop(context); // Kembali ke Dashboard setelah menambahkan
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  food.foodName,
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: lightGreenText),
                                ),
                                Text(
                                  '${food.calories} kcal - ${food.mealType}',
                                  style: TextStyle(fontSize: 14, color: lightGreenText.withOpacity(0.8)),
                                ),
                                if (food.protein != null || food.fat != null || food.carb != null)
                                  Text(
                                    'P: ${food.protein ?? 0}g | L: ${food.fat ?? 0}g | K: ${food.carb ?? 0}g',
                                    style: TextStyle(fontSize: 12, color: lightGreenText.withOpacity(0.7)),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
} 