import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_application_rpl_final/screens/dashboardscreen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_application_rpl_final/widgets/permission_helper.dart';
import 'package:flutter_application_rpl_final/models/add_custom_food_state.dart';
import 'package:flutter_application_rpl_final/utils/macro_estimator.dart';
import 'package:flutter_application_rpl_final/utils/alert_message_factory.dart';

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
  final FoodEntry? existingFood; // Untuk mode edit
  final bool isEditMode; // Flag untuk mode edit

  const AddCustomFoodScreen({
    super.key,
    required this.onFoodAdded,
    this.existingFood,
    this.isEditMode = false,
  });

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
  String?
  _existingImagePath; // Untuk menyimpan path gambar yang sudah ada (asset atau file)
  final ImagePicker _picker = ImagePicker();
  final AudioPlayer _audioPlayer = AudioPlayer();

  // State model untuk validation dan estimation
  late AddCustomFoodState _foodState;
  bool _isEstimating = false; // Flag untuk prevent infinite loop saat auto-fill
  FoodCategory?
  _lastDetectedCategory; // Track kategori terakhir untuk prevent spam notification
  Timer? _debounceTimer; // Timer untuk debounce input

  final List<String> _mealTypes = [
    'Sarapan',
    'Makan Siang',
    'Makan Malam',
    'Cemilan',
  ];

  @override
  void initState() {
    super.initState();
    // Initialize state model
    _foodState = AddCustomFoodState();

    // Jika mode edit, isi field dengan data existing
    if (widget.isEditMode && widget.existingFood != null) {
      final food = widget.existingFood!;
      _foodNameController.text = food.foodName;
      _calorieController.text = food.calories.toString();
      _selectedMealType = food.mealType;
      _proteinController.text = food.protein?.toString() ?? '';
      _fatController.text = food.fat?.toString() ?? '';
      _carbController.text = food.carb?.toString() ?? '';

      // Update state model dengan data existing
      _foodState.updateEstimation(food.foodName, food.calories.toDouble());
      if (food.protein != null) _foodState.updateUserProtein(food.protein!);
      if (food.fat != null) _foodState.updateUserFat(food.fat!);
      if (food.carb != null) _foodState.updateUserCarb(food.carb!);

      if (food.imagePath != null && food.imagePath!.isNotEmpty) {
        // Simpan path gambar yang sudah ada (bisa asset atau file)
        _existingImagePath = food.imagePath;
        // Jika bukan asset, simpan sebagai File juga untuk kompatibilitas
        if (!food.imagePath!.startsWith('lib/')) {
          _imageFile = File(food.imagePath!);
        }
      }
    } else {
      // Mode add baru - setup listeners untuk auto-estimation
      _setupAutoEstimationListeners();
    }

    // Trigger initial validation setelah semua setup
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _validateCurrentState();
      }
    });
  }

  /// Setup listeners untuk auto-estimation saat user input
  void _setupAutoEstimationListeners() {
    _foodNameController.addListener(_onFoodNameChanged);
    _calorieController.addListener(_onCalorieChanged);
    _proteinController.addListener(_onMacroChanged);
    _fatController.addListener(_onMacroChanged);
    _carbController.addListener(_onMacroChanged);
  }

  /// Handler saat nama makanan berubah (dengan debounce)
  void _onFoodNameChanged() {
    // Cancel timer sebelumnya jika ada
    _debounceTimer?.cancel();

    // Set timer baru untuk debounce (500ms)
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (!_isEstimating && _calorieController.text.isNotEmpty && mounted) {
        _triggerEstimation();
      }
    });
  }

  /// Handler saat kalori berubah (dengan debounce)
  void _onCalorieChanged() {
    // Cancel timer sebelumnya jika ada
    _debounceTimer?.cancel();

    // Set timer baru untuk debounce (500ms)
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (!_isEstimating && _foodNameController.text.isNotEmpty && mounted) {
        _triggerEstimation();
      }
    });
  }

  /// Handler saat macro berubah (user edit)
  void _onMacroChanged() {
    if (!_isEstimating) {
      _updateStateFromControllers();
      _validateCurrentState();
    }
  }

  /// Trigger estimation dari nama dan kalori
  void _triggerEstimation() {
    final name = _foodNameController.text.trim();
    final caloriesStr = _calorieController.text.trim();

    if (name.isEmpty || caloriesStr.isEmpty) return;

    final calories = double.tryParse(caloriesStr);
    if (calories == null || calories <= 0) return;

    _isEstimating = true;

    setState(() {
      final previousCategory = _foodState.detectedCategory;
      _foodState.updateEstimation(name, calories);
      final currentCategory = _foodState.detectedCategory;

      // Auto-fill macro jika checkbox "Sudah sesuai?" checked
      // Atau jika field macro masih kosong
      if (_foodState.userAcceptedDefault ||
          (_proteinController.text.isEmpty &&
              _fatController.text.isEmpty &&
              _carbController.text.isEmpty)) {
        _proteinController.text = _foodState.estimatedProtein.toStringAsFixed(
          1,
        );
        _fatController.text = _foodState.estimatedFat.toStringAsFixed(1);
        _carbController.text = _foodState.estimatedCarb.toStringAsFixed(1);

        // Clear user edits karena kita auto-fill dengan estimated
        _foodState.clearUserEdits();
      }

      // Show info hanya jika:
      // 1. Kategori tidak terdeteksi (BALANCED) DAN
      // 2. Kategori berubah dari sebelumnya (prevent spam) ATAU
      // 3. Ini pertama kali (lastDetectedCategory == null)
      if (currentCategory == FoodCategory.BALANCED &&
          name.isNotEmpty &&
          (previousCategory != currentCategory ||
              _lastDetectedCategory != currentCategory)) {
        _lastDetectedCategory = currentCategory;
        final alert = AlertMessageFactory.generateCategoryNotFoundMessage(name);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(alert.message),
              backgroundColor: Colors.blue,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } else if (currentCategory != FoodCategory.BALANCED) {
        // Update last detected category untuk kategori yang terdeteksi
        _lastDetectedCategory = currentCategory;
      }
    });

    _isEstimating = false;
    _validateCurrentState();
  }

  /// Update state dari controllers
  void _updateStateFromControllers() {
    final protein = double.tryParse(_proteinController.text) ?? 0.0;
    final fat = double.tryParse(_fatController.text) ?? 0.0;
    final carb = double.tryParse(_carbController.text) ?? 0.0;

    // Update state hanya jika berbeda dari estimated (user edit)
    if (protein != _foodState.estimatedProtein) {
      _foodState.updateUserProtein(protein);
    } else {
      _foodState.userProtein = null;
    }

    if (fat != _foodState.estimatedFat) {
      _foodState.updateUserFat(fat);
    } else {
      _foodState.userFat = null;
    }

    if (carb != _foodState.estimatedCarb) {
      _foodState.updateUserCarb(carb);
    } else {
      _foodState.userCarb = null;
    }
  }

  /// Validate current state dan update UI
  void _validateCurrentState() {
    final calories = double.tryParse(_calorieController.text) ?? 0.0;
    if (calories <= 0) return;

    _foodState.kalori = calories;
    _foodState.validateCurrent();

    setState(() {
      // Update validation status akan trigger UI update
    });
  }

  /// Get border color berdasarkan validation status
  Color _getBorderColor(String fieldName, Color defaultColor) {
    final alert = _foodState.getAlertForField(fieldName);
    if (alert == null || alert.message.isEmpty) return defaultColor;

    switch (alert.severity) {
      case AlertSeverity.error:
        return Colors.red;
      case AlertSeverity.warning:
        return Colors.orange;
      case AlertSeverity.info:
        return Colors.blue;
    }
  }

  /// Get icon berdasarkan validation status
  Widget? _getValidationIcon(String fieldName) {
    final alert = _foodState.getAlertForField(fieldName);
    if (alert == null || alert.message.isEmpty) {
      // Valid - show check icon (hanya jika field sudah diisi)
      final controller = fieldName == 'protein'
          ? _proteinController
          : fieldName == 'fat'
          ? _fatController
          : _carbController;
      if (controller.text.isNotEmpty) {
        return Icon(Icons.check_circle, color: Colors.green, size: 20);
      }
      return null;
    }

    switch (alert.severity) {
      case AlertSeverity.error:
        return Icon(Icons.error, color: Colors.red, size: 20);
      case AlertSeverity.warning:
        return Icon(Icons.warning, color: Colors.orange, size: 20);
      case AlertSeverity.info:
        return Icon(Icons.info, color: Colors.blue, size: 20);
    }
  }

  /// Show alert dialog
  Future<bool?> _showAlertDialog(AlertMessage alert) async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        final Color darkGreenBg = const Color(0xFF1D362C);
        final Color lightGreenText = const Color(0xFFA2F46E);

        Color titleColor;
        switch (alert.severity) {
          case AlertSeverity.error:
            titleColor = Colors.red;
            break;
          case AlertSeverity.warning:
            titleColor = Colors.orange;
            break;
          case AlertSeverity.info:
            titleColor = Colors.blue;
            break;
        }

        return AlertDialog(
          backgroundColor: darkGreenBg,
          title: Text(
            alert.title,
            style: TextStyle(color: titleColor, fontWeight: FontWeight.bold),
          ),
          content: Text(alert.message, style: TextStyle(color: lightGreenText)),
          actions: alert.actionButtons.map((button) {
            return TextButton(
              onPressed: () {
                if (button.text == 'Lanjut' ||
                    button.text == 'Yakin' ||
                    button.text == 'Review') {
                  Navigator.of(context).pop(true);
                } else {
                  Navigator.of(context).pop(false);
                }
              },
              child: Text(
                button.text,
                style: TextStyle(
                  color: button.isDestructive
                      ? Colors.redAccent
                      : lightGreenText,
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  @override
  void dispose() {
    // Cancel debounce timer
    _debounceTimer?.cancel();

    // Remove listeners untuk prevent memory leaks
    if (!widget.isEditMode) {
      _foodNameController.removeListener(_onFoodNameChanged);
      _calorieController.removeListener(_onCalorieChanged);
      _proteinController.removeListener(_onMacroChanged);
      _fatController.removeListener(_onMacroChanged);
      _carbController.removeListener(_onMacroChanged);
    }

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

  // Fungsi untuk menampilkan gambar (assets atau file)
  Widget _buildImage(Color lightGreenText) {
    // Prioritas: _imageFile (jika ada gambar baru) > _existingImagePath (gambar yang sudah ada)
    String? imagePathToUse = _imageFile?.path ?? _existingImagePath;

    if (imagePathToUse == null || imagePathToUse.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_a_photo, color: lightGreenText, size: 50),
            const SizedBox(height: 8),
            Text(
              widget.isEditMode ? 'Foto Makanan' : 'Ketuk untuk Tambah Foto',
              style: TextStyle(color: lightGreenText.withOpacity(0.7)),
            ),
          ],
        ),
      );
    }

    // Jika path dimulai dengan "lib/", gunakan AssetImage
    if (imagePathToUse.startsWith('lib/')) {
      return Image.asset(
        imagePathToUse,
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
        File(imagePathToUse),
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

  Future<void> _pickImage() async {
    try {
      // Request permission terlebih dahulu
      final hasPermission = await PermissionHelper.requestGalleryPermission(
        context,
      );

      if (!hasPermission) {
        // User menolak permission atau tidak memberikan akses
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Izin akses galeri diperlukan untuk memilih foto.'),
              backgroundColor: Colors.orangeAccent,
            ),
          );
        }
        return;
      }

      // Permission diberikan, lanjutkan memilih gambar
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
      );

      if (pickedFile != null) {
        try {
          // Sementara nonaktifkan crop untuk menghindari crash
          // Gunakan gambar asli langsung
          final appDocDir = await getApplicationDocumentsDirectory();
          final String uniqueFileName =
              '${DateTime.now().millisecondsSinceEpoch}_${pickedFile.name.split('.').last}';
          final File finalImageFile = await File(
            pickedFile.path,
          ).copy('${appDocDir.path}/$uniqueFileName');

          if (mounted) {
            setState(() {
              _imageFile = finalImageFile;
            });
          }
        } catch (e) {
          print('Error saving image: $e');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Gagal menyimpan gambar: $e'),
                backgroundColor: Colors.redAccent,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        }
      } else {
        print('No image selected.');
      }
    } catch (e) {
      print('Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memilih gambar: $e'),
            backgroundColor: Colors.redAccent,
            duration: const Duration(seconds: 3),
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
          widget.isEditMode ? 'Edit Makanan' : 'Tambah Makanan Kustom',
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
                // Foto makanan
                Text(
                  'Foto Makanan ${widget.isEditMode ? '(Tidak Dapat Diubah)' : '(Opsional)'}',
                  style: TextStyle(fontSize: 16, color: lightGreenText),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: widget.isEditMode
                      ? null
                      : _pickImage, // Nonaktifkan di mode edit
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
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: _buildImage(lightGreenText),
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
                    hintStyle: TextStyle(
                      color: lightGreenText.withOpacity(0.6),
                    ),
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
                      borderSide: BorderSide(color: lightGreenText, width: 2.0),
                    ),
                    errorStyle: TextStyle(color: Colors.redAccent),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      _playErrorSound();
                      return 'Jumlah kalori tidak boleh kosong';
                    }
                    final calories = int.tryParse(value);
                    if (calories == null) {
                      _playErrorSound();
                      return 'Masukkan angka yang valid';
                    }
                    if (calories < 0) {
                      _playErrorSound();
                      return 'Kalori tidak boleh minus (minimal 0)';
                    }
                    if (calories == 0) {
                      _playErrorSound();
                      return 'Masukkan angka kalori yang valid (> 0)';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Input Protein dengan visual feedback
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Protein (gram, opsional)',
                        style: TextStyle(fontSize: 16, color: lightGreenText),
                      ),
                    ),
                    if (_getValidationIcon('protein') != null)
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: _getValidationIcon('protein')!,
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _proteinController,
                  style: TextStyle(color: lightGreenText),
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Contoh: 20',
                    hintStyle: TextStyle(
                      color: lightGreenText.withOpacity(0.6),
                    ),
                    filled: true,
                    fillColor: darkGreenBg,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: _getBorderColor('protein', lightGreenText),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: _getBorderColor('protein', lightGreenText),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: _getBorderColor('protein', lightGreenText),
                        width: 2.0,
                      ),
                    ),
                    errorStyle: TextStyle(color: Colors.redAccent),
                  ),
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      final protein = double.tryParse(value);
                      if (protein == null) {
                        _playErrorSound();
                        return 'Masukkan angka yang valid untuk protein';
                      }
                      if (protein < 0) {
                        _playErrorSound();
                        return 'Protein tidak boleh minus (minimal 0)';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Input Lemak dengan visual feedback
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Lemak (gram, opsional)',
                        style: TextStyle(fontSize: 16, color: lightGreenText),
                      ),
                    ),
                    if (_getValidationIcon('fat') != null)
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: _getValidationIcon('fat')!,
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _fatController,
                  style: TextStyle(color: lightGreenText),
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Contoh: 15',
                    hintStyle: TextStyle(
                      color: lightGreenText.withOpacity(0.6),
                    ),
                    filled: true,
                    fillColor: darkGreenBg,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: _getBorderColor('fat', lightGreenText),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: _getBorderColor('fat', lightGreenText),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: _getBorderColor('fat', lightGreenText),
                        width: 2.0,
                      ),
                    ),
                    errorStyle: TextStyle(color: Colors.redAccent),
                  ),
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      final fat = double.tryParse(value);
                      if (fat == null) {
                        _playErrorSound();
                        return 'Masukkan angka yang valid untuk lemak';
                      }
                      if (fat < 0) {
                        _playErrorSound();
                        return 'Lemak tidak boleh minus (minimal 0)';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Input Karbohidrat dengan visual feedback
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Karbohidrat (gram, opsional)',
                        style: TextStyle(fontSize: 16, color: lightGreenText),
                      ),
                    ),
                    if (_getValidationIcon('carb') != null)
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: _getValidationIcon('carb')!,
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _carbController,
                  style: TextStyle(color: lightGreenText),
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Contoh: 40',
                    hintStyle: TextStyle(
                      color: lightGreenText.withOpacity(0.6),
                    ),
                    filled: true,
                    fillColor: darkGreenBg,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: _getBorderColor('carb', lightGreenText),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: _getBorderColor('carb', lightGreenText),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: _getBorderColor('carb', lightGreenText),
                        width: 2.0,
                      ),
                    ),
                    errorStyle: TextStyle(color: Colors.redAccent),
                  ),
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      final carb = double.tryParse(value);
                      if (carb == null) {
                        _playErrorSound();
                        return 'Masukkan angka yang valid untuk karbohidrat';
                      }
                      if (carb < 0) {
                        _playErrorSound();
                        return 'Karbohidrat tidak boleh minus (minimal 0)';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Checkbox "Sudah sesuai?" (hanya untuk mode add, bukan edit)
                if (!widget.isEditMode)
                  CheckboxListTile(
                    title: Text(
                      'Sudah sesuai?',
                      style: TextStyle(fontSize: 16, color: lightGreenText),
                    ),
                    subtitle: Text(
                      'Gunakan estimasi otomatis tanpa edit',
                      style: TextStyle(
                        fontSize: 12,
                        color: lightGreenText.withOpacity(0.7),
                      ),
                    ),
                    value: _foodState.userAcceptedDefault,
                    activeColor: lightGreenText,
                    checkColor: darkGreenBg,
                    onChanged: (bool? value) {
                      setState(() {
                        if (value == true) {
                          _foodState.acceptDefault();
                          // Clear user edits dan reset ke estimated
                          _proteinController.text = _foodState.estimatedProtein
                              .toStringAsFixed(1);
                          _fatController.text = _foodState.estimatedFat
                              .toStringAsFixed(1);
                          _carbController.text = _foodState.estimatedCarb
                              .toStringAsFixed(1);
                        } else {
                          _foodState.rejectDefault();
                        }
                      });
                    },
                  ),
                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        // Update state dari controllers
                        _updateStateFromControllers();

                        final String foodName = _foodNameController.text;
                        final int calories = int.parse(_calorieController.text);
                        final String mealType = _selectedMealType!;

                        // Update state dengan kalori terbaru
                        _foodState.kalori = calories.toDouble();

                        // Validate current state
                        _foodState.validateCurrent();

                        // Check jika ada error yang harus di-block
                        if (_foodState.validationStatus ==
                                ValidationStatus.error &&
                            !_foodState.userOverriddenValidation) {
                          // Show error dialog
                          final errorAlert = _foodState.alerts.isNotEmpty
                              ? _foodState.alerts.firstWhere(
                                  (alert) =>
                                      alert.severity == AlertSeverity.error,
                                  orElse: () => AlertMessage(
                                    severity: AlertSeverity.error,
                                    title: 'Error',
                                    message:
                                        'Terdapat kesalahan pada input. Silakan perbaiki terlebih dahulu.',
                                  ),
                                )
                              : AlertMessage(
                                  severity: AlertSeverity.error,
                                  title: 'Error',
                                  message:
                                      'Terdapat kesalahan pada input. Silakan perbaiki terlebih dahulu.',
                                );

                          await _showAlertDialog(errorAlert);
                          return;
                        }

                        // Check jika ada warning dan user belum override
                        if (_foodState.validationStatus ==
                                ValidationStatus.warning &&
                            !_foodState.userOverriddenValidation) {
                          // Show warning dialog dengan option untuk lanjut
                          final warningAlert = _foodState.alerts.firstWhere(
                            (alert) => alert.severity == AlertSeverity.warning,
                            orElse: () => AlertMessage(
                              severity: AlertSeverity.warning,
                              title: 'Peringatan',
                              message:
                                  'Terdapat peringatan pada input. Lanjutkan?',
                              actionButtons: [
                                ActionButton(text: 'Batal'),
                                ActionButton(text: 'Lanjut'),
                              ],
                            ),
                          );

                          final shouldContinue = await _showAlertDialog(
                            warningAlert,
                          );
                          if (shouldContinue != true) {
                            return; // User cancel
                          }
                          // User lanjut - set override flag
                          _foodState.userOverriddenValidation = true;
                        }

                        // Get final macro values
                        final double? protein = _foodState.activeProtein > 0
                            ? _foodState.activeProtein
                            : null;
                        final double? fat = _foodState.activeFat > 0
                            ? _foodState.activeFat
                            : null;
                        final double? carb = _foodState.activeCarb > 0
                            ? _foodState.activeCarb
                            : null;

                        // Gunakan path gambar yang sudah ada jika mode edit dan tidak ada gambar baru
                        final String? imagePathToSave =
                            widget.isEditMode && _imageFile == null
                            ? _existingImagePath
                            : _imageFile?.path;

                        // Buat FoodEntry untuk dikembalikan
                        final newFoodEntry = FoodEntry(
                          foodName: foodName,
                          calories: calories,
                          mealType: mealType,
                          protein: protein,
                          fat: fat,
                          carb: carb,
                          imagePath: imagePathToSave,
                        );

                        // Panggil callback dengan data yang sudah diisi
                        widget.onFoodAdded(
                          foodName,
                          calories,
                          mealType,
                          protein,
                          fat,
                          carb,
                          imagePathToSave,
                        );

                        if (mounted) {
                          // Kembalikan FoodEntry ke AddFoodScreen
                          Navigator.pop(context, newFoodEntry);
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
                    child: Text(
                      widget.isEditMode ? 'Simpan' : 'Tambahkan Makanan',
                      style: const TextStyle(
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
}
