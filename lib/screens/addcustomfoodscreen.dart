import 'package:flutter/material.dart';
import 'package:flutter_application_rpl_final/screens/dashboardscreen.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_application_rpl_final/widgets/sound_helper.dart';

class AddCustomFoodScreen extends StatefulWidget {
  final Function(
    String foodName,
    int calories,
    String mealType,
    double? protein,
    double? fat,
    double? carb,
    String? imagePath,
  )
  onFoodAdded;

  const AddCustomFoodScreen({super.key, required this.onFoodAdded});

  @override
  State<AddCustomFoodScreen> createState() => _AddCustomFoodScreenState();
}

class _AddCustomFoodScreenState extends State<AddCustomFoodScreen> {
  final TextEditingController _foodNameController = TextEditingController();
  final TextEditingController _calorieController = TextEditingController();
  final TextEditingController _proteinController = TextEditingController();
  final TextEditingController _fatController = TextEditingController();
  final TextEditingController _carbController = TextEditingController();
  String? _selectedMealType;
  final _formKey = GlobalKey<FormState>();
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  final AudioPlayer _audioPlayer = AudioPlayer();

  final List<String> _mealTypes = [
    'Sarapan',
    'Makan Siang',
    'Makan Malam',
    'Cemilan',
  ];

  @override
  void dispose() {
    _foodNameController.dispose();
    _calorieController.dispose();
    _proteinController.dispose();
    _fatController.dispose();
    _carbController.dispose();
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

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      final appDocDir = await getApplicationDocumentsDirectory();
      final String uniqueFileName =
          '${DateTime.now().millisecondsSinceEpoch}_${pickedFile.name.split('.').last}';
      final File newImage = await File(
        pickedFile.path,
      ).copy('${appDocDir.path}/$uniqueFileName');

      setState(() {
        _imageFile = newImage;
      });
    } else {
      print('No image selected.');
    }
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
            await SoundHelper.playTransition();
            if (mounted) {
              Navigator.pop(context);
            }
          },
        ),
        title: Text(
          'Tambah Makanan Kustom',
          style: TextStyle(
            color: lightGreenText,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tombol untuk menambahkan foto
              Text(
                'Foto Makanan (Opsional)',
                style: TextStyle(fontSize: 16, color: lightGreenText),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: lightGreenText.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: lightGreenText.withOpacity(0.5),
                      width: 1,
                    ),
                  ),
                  child: _imageFile != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(_imageFile!, fit: BoxFit.cover),
                        )
                      : Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_a_photo,
                                color: lightGreenText,
                                size: 50,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Ketuk untuk Tambah Foto',
                                style: TextStyle(
                                  color: lightGreenText.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Nama Makanan',
                style: TextStyle(fontSize: 16, color: lightGreenText),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _foodNameController,
                style: TextStyle(color: lightGreenText),
                decoration: InputDecoration(
                  hintText: 'Contoh: Nasi Goreng',
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
                  errorStyle: TextStyle(color: Colors.redAccent),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    _playErrorSound();
                    return 'Nama makanan tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              Text(
                'Jenis Makanan',
                style: TextStyle(fontSize: 16, color: lightGreenText),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _selectedMealType,
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
                  hintStyle: TextStyle(color: lightGreenText.withOpacity(0.6)),
                  errorStyle: TextStyle(color: Colors.redAccent),
                ),
                icon: Icon(Icons.arrow_drop_down, color: lightGreenText),
                style: TextStyle(color: lightGreenText, fontSize: 16),
                items: _mealTypes.map((String mealType) {
                  return DropdownMenuItem<String>(
                    value: mealType,
                    child: Text(
                      mealType,
                      style: TextStyle(color: lightGreenText),
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedMealType = newValue;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    _playErrorSound();
                    return 'Pilih jenis makanan';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              Text(
                'Jumlah Kalori (kcal)',
                style: TextStyle(fontSize: 16, color: lightGreenText),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _calorieController,
                style: TextStyle(color: lightGreenText),
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Contoh: 350',
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
                  errorStyle: TextStyle(color: Colors.redAccent),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    _playErrorSound();
                    return 'Jumlah kalori tidak boleh kosong';
                  }
                  if (int.tryParse(value) == null || int.parse(value) <= 0) {
                    _playErrorSound();
                    return 'Masukkan angka kalori yang valid (> 0)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Input Protein
              Text(
                'Protein (gram, opsional)',
                style: TextStyle(fontSize: 16, color: lightGreenText),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _proteinController,
                style: TextStyle(color: lightGreenText),
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Contoh: 20',
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
                  errorStyle: TextStyle(color: Colors.redAccent),
                ),
                validator: (value) {
                  if (value != null &&
                      value.isNotEmpty &&
                      double.tryParse(value) == null) {
                    _playErrorSound();
                    return 'Masukkan angka yang valid untuk protein';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Input Lemak
              Text(
                'Lemak (gram, opsional)',
                style: TextStyle(fontSize: 16, color: lightGreenText),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _fatController,
                style: TextStyle(color: lightGreenText),
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Contoh: 15',
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
                  errorStyle: TextStyle(color: Colors.redAccent),
                ),
                validator: (value) {
                  if (value != null &&
                      value.isNotEmpty &&
                      double.tryParse(value) == null) {
                    _playErrorSound();
                    return 'Masukkan angka yang valid untuk lemak';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Input Karbohidrat
              Text(
                'Karbohidrat (gram, opsional)',
                style: TextStyle(fontSize: 16, color: lightGreenText),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _carbController,
                style: TextStyle(color: lightGreenText),
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Contoh: 40',
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
                  errorStyle: TextStyle(color: Colors.redAccent),
                ),
                validator: (value) {
                  if (value != null &&
                      value.isNotEmpty &&
                      double.tryParse(value) == null) {
                    _playErrorSound();
                    return 'Masukkan angka yang valid untuk karbohidrat';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final String foodName = _foodNameController.text;
                      final int calories = int.parse(_calorieController.text);
                      final String mealType = _selectedMealType!;
                      final double? protein = double.tryParse(
                        _proteinController.text,
                      );
                      final double? fat = double.tryParse(_fatController.text);
                      final double? carb = double.tryParse(
                        _carbController.text,
                      );

                      final newFoodEntry = FoodEntry(
                        foodName: foodName,
                        calories: calories,
                        mealType: mealType,
                        protein: protein,
                        fat: fat,
                        carb: carb,
                        imagePath: _imageFile?.path,
                      );
                      await SoundHelper.playTransition();
                      if (mounted) {
                        Navigator.pop(
                          context,
                          newFoodEntry,
                        ); // Mengembalikan FoodEntry
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
