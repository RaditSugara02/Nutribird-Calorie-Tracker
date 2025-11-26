import 'package:flutter/material.dart';
import 'package:flutter_application_rpl_final/screens/dashboardscreen.dart';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';

class FoodDetailScreen extends StatefulWidget {
  final FoodEntry food;

  const FoodDetailScreen({super.key, required this.food});

  @override
  State<FoodDetailScreen> createState() => _FoodDetailScreenState();
}

class _FoodDetailScreenState extends State<FoodDetailScreen> {
  final TextEditingController _quantityController = TextEditingController();
  String _selectedUnit = 'gram'; // Default unit
  final double _defaultServingSize = 100.0; // Gram per porsi default
  String?
  _selectedMealType; // Tambahkan ini untuk menyimpan jenis makanan yang dipilih
  final _formKey = GlobalKey<FormState>();
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    // Set default quantity to default serving size
    _quantityController.text = _defaultServingSize.toStringAsFixed(0);
    print(
      'FoodDetailScreen: Initialized with food: ${widget.food.foodName}, calories: ${widget.food.calories}',
    );
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  // Fungsi untuk memutar suara error
  void _playErrorSound() {
    try {
      _audioPlayer.play(AssetSource('error.wav'));
    } catch (e) {
      print('Error playing sound: $e');
    }
  }

  // Fungsi untuk menampilkan gambar (assets atau file)
  Widget _buildImage(Color lightGreenText) {
    final imagePath = widget.food.imagePath!;

    // Jika path dimulai dengan "lib/", gunakan AssetImage
    if (imagePath.startsWith('lib/')) {
      return Image.asset(
        imagePath,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: lightGreenText.withOpacity(0.1),
            child: Center(
              child: Icon(
                Icons.broken_image,
                color: lightGreenText.withOpacity(0.5),
                size: 50,
              ),
            ),
          );
        },
      );
    } else {
      // Jika bukan asset, gunakan File (untuk gambar yang dipilih user)
      return Image.file(
        File(imagePath),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: lightGreenText.withOpacity(0.1),
            child: Center(
              child: Icon(
                Icons.broken_image,
                color: lightGreenText.withOpacity(0.5),
                size: 50,
              ),
            ),
          );
        },
      );
    }
  }

  // Fungsi untuk menghitung ulang makronutrien berdasarkan kuantitas yang dimasukkan
  FoodEntry _calculateAdjustedFood() {
    double quantity = double.tryParse(_quantityController.text) ?? 0.0;
    if (quantity == 0) {
      return widget.food; // Return original if quantity is 0 or invalid
    }

    double ratio;
    if (_selectedUnit == 'gram') {
      // Jika unit adalah gram, rasio adalah kuantitas / 100 (karena data dasar biasanya per 100g)
      // Asumsi: kalori dan makro di FoodEntry adalah per 100 gram atau per default serving size
      // Untuk saat ini, kita asumsikan kalori dan makro di FoodEntry adalah untuk _defaultServingSize
      ratio = quantity / _defaultServingSize;
    } else {
      // Jika unit adalah porsi, asumsikan 1 porsi = _defaultServingSize gram
      // Jadi, kuantitas adalah jumlah porsi
      ratio =
          quantity; // Jika kuantitas adalah porsi, maka rasio langsung jumlah porsi
    }

    // Pastikan kalori tidak minus
    final int calculatedCalories = (widget.food.calories * ratio).round();
    final int safeCalories = calculatedCalories < 0 ? 0 : calculatedCalories;

    // Pastikan macronutrients tidak minus
    final double calculatedProtein = (widget.food.protein ?? 0) * ratio;
    final double calculatedFat = (widget.food.fat ?? 0) * ratio;
    final double calculatedCarb = (widget.food.carb ?? 0) * ratio;

    final double safeProtein = calculatedProtein < 0 ? 0.0 : calculatedProtein;
    final double safeFat = calculatedFat < 0 ? 0.0 : calculatedFat;
    final double safeCarb = calculatedCarb < 0 ? 0.0 : calculatedCarb;

    return FoodEntry(
      foodName: widget.food.foodName,
      calories: safeCalories,
      mealType: _selectedMealType ?? widget.food.mealType,
      protein: safeProtein,
      fat: safeFat,
      carb: safeCarb,
      imagePath: widget.food.imagePath,
    );
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
          onPressed: () async {
            print('FoodDetailScreen: Back button pressed.');
            if (mounted) {
              Navigator.pop(context); // Kembali tanpa data
            }
          },
        ),
        title: Text(
          widget.food.foodName,
          style: TextStyle(
            color: lightGreenText,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            left: 24.0,
            right: 24.0,
            top: 24.0,
            bottom: 24.0 + MediaQuery.of(context).padding.bottom,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Detail Makanan',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: lightGreenText,
                  ),
                ),
                const SizedBox(height: 16),
                // Tampilkan gambar jika ada
                if (widget.food.imagePath != null &&
                    widget.food.imagePath!.isNotEmpty)
                  Container(
                    height: 200,
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: lightGreenText.withOpacity(0.5),
                        width: 1,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: _buildImage(lightGreenText),
                    ),
                  ),
                Card(
                  color: darkGreenBg,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(
                      color: lightGreenText.withOpacity(0.5),
                      width: 1,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Informasi Nutrisi',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: lightGreenText,
                          ),
                        ),
                        Divider(color: lightGreenText, thickness: 5),
                        const SizedBox(height: 4),
                        Text(
                          'Jumlah per Sajian',
                          style: TextStyle(fontSize: 16, color: lightGreenText),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Kalori',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: lightGreenText,
                              ),
                            ),
                            Text(
                              '${widget.food.calories}',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: lightGreenText,
                              ),
                            ),
                          ],
                        ),
                        Divider(color: lightGreenText, thickness: 1),
                        const SizedBox(height: 8),
                        _buildNutrientRow(
                          'Protein',
                          widget.food.protein,
                          'g',
                          lightGreenText,
                        ),
                        _buildNutrientRow(
                          'Lemak',
                          widget.food.fat,
                          'g',
                          lightGreenText,
                        ),
                        _buildNutrientRow(
                          'Karbohidrat',
                          widget.food.carb,
                          'g',
                          lightGreenText,
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _quantityController,
                        style: TextStyle(color: lightGreenText),
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Jumlah',
                          labelStyle: TextStyle(
                            color: lightGreenText.withOpacity(0.8),
                          ),
                          hintText: 'Contoh: 100',
                          hintStyle: TextStyle(
                            color: lightGreenText.withOpacity(0.6),
                          ),
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
                            borderSide: BorderSide(
                              color: lightGreenText,
                              width: 2.0,
                            ),
                          ),
                          errorStyle: TextStyle(color: Colors.redAccent),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 12.0,
                            horizontal: 16.0,
                          ),
                          isDense: true,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            _playErrorSound(); // Play error sound ketika validator ter-trigger
                            return 'Jumlah tidak boleh kosong';
                          }
                          if (double.tryParse(value) == null ||
                              double.parse(value) <= 0) {
                            _playErrorSound(); // Play error sound ketika validator ter-trigger
                            return 'Masukkan angka yang valid (> 0)';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedUnit,
                        dropdownColor: darkGreenBg,
                        decoration: InputDecoration(
                          labelText: 'Satuan',
                          labelStyle: TextStyle(
                            color: lightGreenText.withOpacity(0.8),
                          ),
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
                            borderSide: BorderSide(
                              color: lightGreenText,
                              width: 2.0,
                            ),
                          ),
                          hintStyle: TextStyle(
                            color: lightGreenText.withOpacity(0.6),
                          ),
                          errorStyle: TextStyle(color: Colors.redAccent),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 12.0,
                            horizontal: 16.0,
                          ),
                          isDense: true,
                        ),
                        icon: Icon(
                          Icons.arrow_drop_down,
                          color: lightGreenText,
                        ),
                        style: TextStyle(color: lightGreenText, fontSize: 16),
                        items: <String>['gram', 'porsi'].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                              style: TextStyle(color: lightGreenText),
                            ),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedUnit = newValue!;
                            // Sesuaikan nilai controller jika unit berubah
                            if (_selectedUnit == 'porsi' &&
                                double.tryParse(_quantityController.text) ==
                                    _defaultServingSize) {
                              _quantityController.text = '1'; // Default 1 porsi
                            } else if (_selectedUnit == 'gram' &&
                                double.tryParse(_quantityController.text) ==
                                    1) {
                              _quantityController.text = _defaultServingSize
                                  .toStringAsFixed(
                                    0,
                                  ); // Default ke gram per porsi
                            }
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  'Jenis Makanan',
                  style: TextStyle(fontSize: 16, color: lightGreenText),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue:
                      _selectedMealType ??
                      widget
                          .food
                          .mealType, // Gunakan nilai dari FoodEntry jika tidak ada yang dipilih
                  dropdownColor: darkGreenBg,
                  decoration: InputDecoration(
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
                    hintStyle: TextStyle(
                      color: lightGreenText.withOpacity(0.6),
                    ),
                    errorStyle: TextStyle(color: Colors.redAccent),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 12.0,
                      horizontal: 16.0,
                    ),
                  ),
                  icon: Icon(Icons.arrow_drop_down, color: lightGreenText),
                  style: TextStyle(color: lightGreenText, fontSize: 16),
                  items:
                      <String>[
                        'Sarapan',
                        'Makan Siang',
                        'Makan Malam',
                        'Cemilan',
                      ].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            value,
                            style: TextStyle(color: lightGreenText),
                          ),
                        );
                      }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedMealType = newValue!;
                    });
                  },
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      // Validasi menggunakan Form validator
                      if (_formKey.currentState!.validate()) {
                        // Kembali tanpa suara (success sound akan diputar di AddFoodScreen)
                        if (mounted) {
                          final adjustedFood = _calculateAdjustedFood();
                          Navigator.pop(
                            context,
                            adjustedFood,
                          ); // Kembali dengan FoodEntry yang disesuaikan
                        }
                      } else {
                        // Validator sudah ter-trigger dan akan memutar suara error
                        // Jika tidak ada Form validation yang ter-trigger, cek manual
                        if (_quantityController.text.isEmpty ||
                            double.tryParse(_quantityController.text) == null ||
                            double.parse(_quantityController.text) <= 0) {
                          _playErrorSound(); // Play error sound untuk validasi manual
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Masukkan jumlah yang valid.'),
                            ),
                          );
                        }
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
                      'Tambahkan Makanan',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNutrientRow(
    String nutrientName,
    double? nutrientValue,
    String unit,
    Color textColor,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(nutrientName, style: TextStyle(fontSize: 16, color: textColor)),
        Text(
          '${nutrientValue ?? 0}$unit',
          style: TextStyle(fontSize: 16, color: textColor),
        ),
      ],
    );
  }
}
