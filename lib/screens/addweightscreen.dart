import 'package:flutter/material.dart';

class AddWeightScreen extends StatefulWidget {
  final Function(double weight) onWeightAdded;

  const AddWeightScreen({
    super.key,
    required this.onWeightAdded,
  });

  @override
  State<AddWeightScreen> createState() => _AddWeightScreenState();
}

class _AddWeightScreenState extends State<AddWeightScreen> {
  final TextEditingController _weightController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _weightController.dispose();
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
          'Catat Berat Badan',
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
                'Berat Badan (kg)',
                style: TextStyle(fontSize: 16, color: lightGreenText),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _weightController,
                style: TextStyle(color: lightGreenText),
                keyboardType: TextInputType.number, // Memastikan input numerik
                decoration: InputDecoration(
                  hintText: 'Contoh: 65.5',
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
                    return 'Berat badan tidak boleh kosong';
                  }
                  if (double.tryParse(value) == null || double.parse(value) <= 0) {
                    return 'Masukkan angka berat badan yang valid (> 0)';
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
                      final double weight = double.parse(_weightController.text);
                      widget.onWeightAdded(weight);
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
                    'Catat Berat Badan',
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