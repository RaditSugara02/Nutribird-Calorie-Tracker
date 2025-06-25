import 'package:flutter/material.dart';

class AddActivityScreen extends StatefulWidget {
  final Function(String activityName, int caloriesBurned) onActivityAdded; // Callback

  const AddActivityScreen({
    super.key,
    required this.onActivityAdded,
  });

  @override
  State<AddActivityScreen> createState() => _AddActivityScreenState();
}

class _AddActivityScreenState extends State<AddActivityScreen> {
  final TextEditingController _activityNameController = TextEditingController();
  final TextEditingController _caloriesBurnedController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _activityNameController.dispose();
    _caloriesBurnedController.dispose();
    super.dispose();
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
          'Tambah Aktivitas',
          style: TextStyle(color: lightGreenText, fontSize: 20, fontWeight: FontWeight.bold),
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
              Text(
                'Nama Aktivitas',
                style: TextStyle(fontSize: 16, color: lightGreenText),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _activityNameController,
                style: TextStyle(color: lightGreenText),
                decoration: InputDecoration(
                  hintText: 'Contoh: Lari Pagi',
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
                    return 'Nama aktivitas tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              Text(
                'Kalori Dibakar (kcal)',
                style: TextStyle(fontSize: 16, color: lightGreenText),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _caloriesBurnedController,
                style: TextStyle(color: lightGreenText),
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Contoh: 250',
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
                    return 'Jumlah kalori tidak boleh kosong';
                  }
                  if (int.tryParse(value) == null || int.parse(value) <= 0) {
                    return 'Masukkan angka kalori yang valid (> 0)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      final String activityName = _activityNameController.text;
                      final int caloriesBurned = int.parse(_caloriesBurnedController.text);
                      widget.onActivityAdded(activityName, caloriesBurned);
                      Navigator.pop(context);
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
                    'Tambahkan Aktivitas',
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