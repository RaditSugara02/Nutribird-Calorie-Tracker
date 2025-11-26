import 'package:flutter/material.dart';
import 'package:flutter_application_rpl_final/screens/dashboardscreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter_application_rpl_final/screens/addcustomfoodscreen.dart';
import 'package:flutter_application_rpl_final/screens/fooddetailscreen.dart';
import 'package:flutter_application_rpl_final/widgets/sound_helper.dart';
import 'package:flutter_application_rpl_final/widgets/custom_page_route.dart';

class AddFoodScreen extends StatefulWidget {
  final Function(
    String foodName,
    int calories,
    String mealType,
    double? protein,
    double? fat,
    double? carb,
    String? imagePath,
  )
  onFoodAdded; // Callback baru

  const AddFoodScreen({super.key, required this.onFoodAdded});

  @override
  State<AddFoodScreen> createState() => _AddFoodScreenState();
}

class _AddFoodScreenState extends State<AddFoodScreen>
    with SingleTickerProviderStateMixin {
  // Data makanan yang sudah ditetapkan (akan dimuat dan ditambahkan pengguna)
  List<FoodEntry> _defaultFoods = [];
  List<FoodEntry> _userFoods = [];
  List<FoodEntry> _filteredDefaultFoods = [];
  List<FoodEntry> _filteredUserFoods = [];
  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;

  // Flag untuk mencegah multiple navigation
  bool _isNavigating = false;

  // Data makanan yang sudah ditetapkan secara default
  final List<FoodEntry> _defaultPredefinedFoods = [
    FoodEntry(
      foodName: 'Nasi Putih',
      calories: 200,
      mealType: 'Makan Siang',
      protein: 4.0,
      fat: 0.5,
      carb: 45.0,
      imagePath: 'lib/img/Nasi Putih.jpg',
    ),
    FoodEntry(
      foodName: 'Ayam Goreng',
      calories: 300,
      mealType: 'Makan Malam',
      protein: 30.0,
      fat: 20.0,
      carb: 0.0,
      imagePath: 'lib/img/Ayam Goreng.jpg',
    ),
    FoodEntry(
      foodName: 'Telur Rebus',
      calories: 80,
      mealType: 'Sarapan',
      protein: 7.0,
      fat: 5.0,
      carb: 0.5,
      imagePath: 'lib/img/Telur Rebus.jpg',
    ),
    FoodEntry(
      foodName: 'Pisang',
      calories: 100,
      mealType: 'Cemilan',
      protein: 1.0,
      fat: 0.3,
      carb: 27.0,
      imagePath: 'lib/img/Pisang.jpg',
    ),
    FoodEntry(
      foodName: 'Salad Sayur',
      calories: 150,
      mealType: 'Makan Siang',
      protein: 5.0,
      fat: 10.0,
      carb: 15.0,
      imagePath: 'lib/img/Salad Sayur.jpg',
    ),
    FoodEntry(
      foodName: 'Oatmeal',
      calories: 180,
      mealType: 'Sarapan',
      protein: 6.0,
      fat: 3.0,
      carb: 30.0,
      imagePath: 'lib/img/Oatmeal.jpg',
    ),
    FoodEntry(
      foodName: 'Tahu Goreng',
      calories: 120,
      mealType: 'Makan Siang',
      protein: 10.0,
      fat: 8.0,
      carb: 2.0,
      imagePath: 'lib/img/Tahu Goreng.jpg',
    ),
    FoodEntry(
      foodName: 'Susu Full Cream',
      calories: 150,
      mealType: 'Sarapan',
      protein: 8.0,
      fat: 8.0,
      carb: 12.0,
      imagePath: 'lib/img/Susu Full Creamy.jpg',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _filterFoods(); // Refresh filter saat tab berubah
      });
    });
    _loadAllFoods();
    _searchController.addListener(_filterFoods);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  // Fungsi untuk memuat semua makanan (pradefinisi + ditambahkan pengguna)
  Future<void> _loadAllFoods() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? userFoodEntriesJson = prefs.getStringList(
      'user_food_entries',
    );

    List<FoodEntry> loadedUserFoods = [];
    if (userFoodEntriesJson != null) {
      loadedUserFoods = userFoodEntriesJson
          .map((entryJson) => FoodEntry.fromJson(jsonDecode(entryJson)))
          .toList();
    }

    setState(() {
      // Pisahkan makanan default dan makanan user
      _defaultFoods = List.from(_defaultPredefinedFoods);
      _userFoods = loadedUserFoods;
      _filterFoods(); // Terapkan filter awal
    });
  }

  // Fungsi untuk menyimpan makanan yang ditambahkan pengguna
  Future<void> _saveUserFoods() async {
    final prefs = await SharedPreferences.getInstance();
    // Simpan hanya makanan user yang ada di _userFoods
    final List<String> userFoodEntriesJson = _userFoods
        .map((entry) => jsonEncode(entry.toJson()))
        .toList();
    await prefs.setStringList('user_food_entries', userFoodEntriesJson);
  }

  // Fungsi untuk menghapus makanan user
  Future<void> _deleteUserFood(FoodEntry food) async {
    // Pastikan hanya makanan user yang bisa dihapus
    if (!_isUserFood(food)) {
      return; // Jangan hapus makanan default
    }

    // Konfirmasi penghapusan
    final bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        final Color darkGreenBg = const Color(0xFF1D362C);
        final Color lightGreenText = const Color(0xFFA2F46E);

        return AlertDialog(
          backgroundColor: darkGreenBg,
          title: Text('Hapus Makanan', style: TextStyle(color: lightGreenText)),
          content: Text(
            'Apakah Anda yakin ingin menghapus "${food.foodName}"?',
            style: TextStyle(color: lightGreenText.withOpacity(0.9)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Batal',
                style: TextStyle(color: lightGreenText.withOpacity(0.7)),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Hapus', style: TextStyle(color: Colors.redAccent)),
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      setState(() {
        // Hapus dari list user foods
        _userFoods.removeWhere((f) => f.foodName == food.foodName);
        _filterFoods(); // Update filtered list
      });
      // Simpan perubahan ke SharedPreferences
      await _saveUserFoods();

      // Play success sound ketika makanan berhasil dihapus
      await SoundHelper.playSuccess();

      // Tampilkan snackbar konfirmasi
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${food.foodName} telah dihapus'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  // Fungsi untuk mengecek apakah makanan adalah user food entry
  bool _isUserFood(FoodEntry food) {
    // Cek apakah makanan ada di list default predefined foods berdasarkan nama
    return !_defaultPredefinedFoods.any(
      (defaultFood) => defaultFood.foodName == food.foodName,
    );
  }

  void _filterFoods() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      // Filter makanan default
      _filteredDefaultFoods = _defaultFoods.where((food) {
        return food.foodName.toLowerCase().contains(query);
      }).toList();

      // Filter makanan user
      _filteredUserFoods = _userFoods.where((food) {
        return food.foodName.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final Color darkGreenBg = const Color(0xFF1D362C);
    final Color lightGreenText = const Color(0xFFA2F46E);

    return Scaffold(
      backgroundColor: darkGreenBg,
      appBar: AppBar(
        backgroundColor: darkGreenBg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: lightGreenText),
          onPressed: () async {
            if (mounted) {
              Navigator.pop(context);
            }
          },
        ),
        title: Text(
          'Tambah Makanan',
          style: TextStyle(
            color: lightGreenText,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              Icons.add,
              color: lightGreenText,
            ), // Icon tambah untuk makanan kustom
            onPressed: () async {
              if (_isNavigating) return;
              _isNavigating = true;
              if (!mounted) {
                _isNavigating = false;
                return;
              }
              final newFood = await Navigator.push(
                context,
                CustomPageRoute(
                  child: AddCustomFoodScreen(
                    // Halaman baru
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
                          // Callback dari AddCustomFoodScreen
                          return FoodEntry(
                            foodName: foodName,
                            calories: calories,
                            mealType: mealType,
                            protein: protein,
                            fat: fat,
                            carb: carb,
                            imagePath: imagePath,
                          );
                        },
                  ),
                  backgroundColor: const Color(0xFF1D362C),
                ),
              ); // end of await Navigator.push
              _isNavigating = false;

              if (newFood != null && newFood is FoodEntry) {
                // Cek apakah makanan sudah ada di list (untuk menghindari duplikasi)
                final bool foodExists = _userFoods.any(
                  (food) => food.foodName == newFood.foodName,
                );

                if (!foodExists) {
                  setState(() {
                    // Tambahkan makanan kustom ke daftar user foods
                    _userFoods.add(newFood);
                    _filterFoods(); // Perbarui daftar yang difilter
                  });
                  await _saveUserFoods(); // Simpan makanan yang ditambahkan pengguna
                } else {
                  // Jika makanan sudah ada, reload untuk memastikan data terbaru
                  await _loadAllFoods();
                }

                // Pindah ke tab "Makanan User" setelah menambahkan makanan baru
                _tabController.animateTo(1);
              } else {
                // Reload semua makanan untuk memastikan data terbaru (jika tidak ada makanan baru)
                await _loadAllFoods();
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextFormField(
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
          ),
          // Tab Bar
          TabBar(
            controller: _tabController,
            indicatorColor: lightGreenText,
            dividerColor: darkGreenBg, // Garis divider hijau gelap
            labelColor: lightGreenText,
            unselectedLabelColor: lightGreenText.withOpacity(0.5),
            labelStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            unselectedLabelStyle: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.normal,
            ),
            tabs: [
              Tab(text: 'Rekomendasi'),
              Tab(text: 'Makanan Saya'),
            ],
          ),
          // Tab Bar View
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Tab Default Foods
                _buildFoodList(_filteredDefaultFoods, false),
                // Tab User Foods
                _buildFoodList(_filteredUserFoods, true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget untuk membangun list makanan
  Widget _buildFoodList(List<FoodEntry> foods, bool isUserFood) {
    final Color darkGreenBg = const Color(0xFF1D362C);
    final Color lightGreenText = const Color(0xFFA2F46E);

    if (foods.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.fastfood_outlined,
                size: 64,
                color: lightGreenText.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                isUserFood
                    ? 'Belum ada makanan yang ditambahkan'
                    : 'Tidak ada makanan yang ditemukan',
                style: TextStyle(
                  color: lightGreenText.withOpacity(0.7),
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: foods.length,
      itemBuilder: (context, index) {
        final food = foods[index];
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
              if (_isNavigating) return;
              _isNavigating = true;
              if (!mounted) {
                _isNavigating = false;
                return;
              }
              final FoodEntry? adjustedFood = await Navigator.push(
                context,
                CustomPageRoute(
                  child: FoodDetailScreen(
                    food: food,
                  ), // Navigasi ke FoodDetailScreen
                  backgroundColor: const Color(0xFF1D362C),
                ),
              );
              _isNavigating = false;

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
                // Play success sound ketika makanan berhasil ditambahkan
                await SoundHelper.playSuccess();
                await Future.delayed(const Duration(milliseconds: 300));
                // Kembali ke Dashboard tanpa transisi sound
                if (mounted) {
                  Navigator.pop(
                    context,
                  ); // Kembali ke Dashboard setelah menambahkan
                }
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
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: lightGreenText,
                          ),
                        ),
                        Text(
                          '${food.calories} kcal - ${food.mealType}',
                          style: TextStyle(
                            fontSize: 14,
                            color: lightGreenText.withOpacity(0.8),
                          ),
                        ),
                        if (food.protein != null ||
                            food.fat != null ||
                            food.carb != null)
                          Text(
                            'P: ${food.protein ?? 0}g | L: ${food.fat ?? 0}g | K: ${food.carb ?? 0}g',
                            style: TextStyle(
                              fontSize: 12,
                              color: lightGreenText.withOpacity(0.7),
                            ),
                          ),
                      ],
                    ),
                  ),
                  // Tampilkan icon trash bin hanya untuk user food entries
                  if (isUserFood)
                    GestureDetector(
                      onTap: () => _deleteUserFood(food),
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Icon(
                          Icons.delete_outline,
                          color: Colors.redAccent.withOpacity(0.8),
                          size: 24,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
