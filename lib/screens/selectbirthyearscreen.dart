import 'package:flutter/material.dart';
import 'package:flutter_application_rpl_final/screens/inputheightscreen.dart';
import 'package:flutter_application_rpl_final/widgets/progress_bar.dart';

class SelectBirthYearScreen extends StatefulWidget {
  final String name;
  final String gender;
  final String email;
  final String password;

  const SelectBirthYearScreen({super.key, required this.name, required this.gender, required this.email, required this.password});

  @override
  State<SelectBirthYearScreen> createState() => _SelectBirthYearScreenState();
}

class _SelectBirthYearScreenState extends State<SelectBirthYearScreen> {
  final _formKey = GlobalKey<FormState>();
  int? _selectedDay;
  int? _selectedMonth;
  int? _selectedYear;

  final FixedExtentScrollController _dayController = FixedExtentScrollController();
  final FixedExtentScrollController _monthController = FixedExtentScrollController();
  final FixedExtentScrollController _yearController = FixedExtentScrollController();

  List<int> daysInMonth = List.generate(31, (index) => index + 1); // Max 31 days
  List<String> months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
  ];
  List<int> years = List.generate(100, (index) => DateTime.now().year - index); // Last 100 years

  @override
  void initState() {
    super.initState();
    // Set initial values to current date or a reasonable default
    _selectedDay = DateTime.now().day;
    _selectedMonth = DateTime.now().month;
    _selectedYear = DateTime.now().year;

    // Initialize scroll controllers to show current date
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _dayController.jumpToItem(_selectedDay! - 1);
      _monthController.jumpToItem(_selectedMonth! - 1);
      _yearController.jumpToItem(years.indexOf(_selectedYear!));
    });
  }

  @override
  void dispose() {
    _dayController.dispose();
    _monthController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  // Helper function to get days in a specific month and year (for leap years)
  int _getDaysInMonth(int month, int year) {
    if (month == 2) {
      if ((year % 4 == 0 && year % 100 != 0) || (year % 400 == 0)) {
        return 29; // Leap year
      } else {
        return 28;
      }
    } else if ([4, 6, 9, 11].contains(month)) {
      return 30;
    } else {
      return 31;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color darkGreenBg = const Color(0xFF1D362C);
    final Color lightGreenText = const Color(0xFFA2F46E);
    final Color darkText = const Color(0xFF112D21);

    return Scaffold(
      backgroundColor: darkGreenBg,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios, color: lightGreenText),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 20.0), // Adjust padding as needed
                      child: ProgressBar(currentStep: 3, totalSteps: 7),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                'Kapan Anda lahir?',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: lightGreenText,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Membantu kami memahami rentang usia Anda.',
                style: TextStyle(
                  fontSize: 16,
                  color: lightGreenText.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildDatePickerColumn(
                    label: 'Tanggal',
                    controller: _dayController,
                    childCount: daysInMonth.length,
                    selectedIndex: _selectedDay != null ? _selectedDay! - 1 : 0,
                    onSelectedItemChanged: (index) {
                      setState(() {
                        _selectedDay = daysInMonth[index];
                      });
                    },
                    itemBuilder: (context, index) => Text(daysInMonth[index].toString().padLeft(2, '0'),
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: index == _selectedDay! - 1 ? lightGreenText : lightGreenText.withOpacity(0.6))), // Highlight selected
                  ),
                  _buildDatePickerColumn(
                    label: 'Bulan',
                    controller: _monthController,
                    childCount: months.length,
                    selectedIndex: _selectedMonth != null ? _selectedMonth! - 1 : 0,
                    onSelectedItemChanged: (index) {
                      setState(() {
                        _selectedMonth = index + 1;
                        // Adjust days in month if necessary after month change
                        daysInMonth = List.generate(_getDaysInMonth(_selectedMonth!, _selectedYear!), (idx) => idx + 1);
                        if (_selectedDay! > daysInMonth.length) {
                          _selectedDay = daysInMonth.length; // Adjust day if it exceeds new max days
                          _dayController.jumpToItem(_selectedDay! - 1);
                        }
                      });
                    },
                    itemBuilder: (context, index) => Text(months[index],
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: index == _selectedMonth! - 1 ? lightGreenText : lightGreenText.withOpacity(0.6))), // Highlight selected
                  ),
                  _buildDatePickerColumn(
                    label: 'Tahun',
                    controller: _yearController,
                    childCount: years.length,
                    selectedIndex: _selectedYear != null ? years.indexOf(_selectedYear!) : 0,
                    onSelectedItemChanged: (index) {
                      setState(() {
                        _selectedYear = years[index];
                        // Adjust days in month if necessary after year change (leap year check)
                        daysInMonth = List.generate(_getDaysInMonth(_selectedMonth!, _selectedYear!), (idx) => idx + 1);
                        if (_selectedDay! > daysInMonth.length) {
                          _selectedDay = daysInMonth.length; // Adjust day if it exceeds new max days
                          _dayController.jumpToItem(_selectedDay! - 1);
                        }
                      });
                    },
                    itemBuilder: (context, index) => Text(years[index].toString(),
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: index == years.indexOf(_selectedYear!) ? lightGreenText : lightGreenText.withOpacity(0.6))), // Highlight selected
                  ),
                ],
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_selectedDay != null && _selectedMonth != null && _selectedYear != null) {
                      final int currentYear = DateTime.now().year;
                      final int age = currentYear - _selectedYear!;

                      if (age < 15 || age > 80) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Usia harus antara 15 dan 80 tahun untuk perhitungan kalori.')),
                        );
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => InputHeightScreen(
                              name: widget.name,
                              gender: widget.gender,
                              birthDay: _selectedDay!,
                              birthMonth: _selectedMonth!,
                              birthYear: _selectedYear!,
                              email: widget.email,
                              password: widget.password,
                            ),
                          ),
                        );
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Mohon pilih tanggal lahir lengkap Anda')),
                      );
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
                    'Lanjutkan',
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

  Widget _buildDatePickerColumn({
    required String label,
    required FixedExtentScrollController controller,
    required int childCount,
    required int selectedIndex,
    required ValueChanged<int> onSelectedItemChanged,
    required IndexedWidgetBuilder itemBuilder,
  }) {
    final Color lightGreenText = const Color(0xFFA2F46E);
    final Color darkGreenBg = const Color(0xFF1D362C);

    return Column(
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 14, color: lightGreenText.withOpacity(0.8)),
        ),
        const SizedBox(height: 8),
        Container(
          height: 200, // Height of the scrollable area
          width: 80, // Width of each column
          decoration: BoxDecoration(
            color: darkGreenBg, // Background of the picker column
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: lightGreenText, width: 1),
          ),
          child: ListWheelScrollView.useDelegate(
            controller: controller,
            itemExtent: 50, // Height of each item
            perspective: 0.005, // Perspective effect
            diameterRatio: 1.2, // Controls the curvature
            physics: const FixedExtentScrollPhysics(),
            onSelectedItemChanged: onSelectedItemChanged,
            childDelegate: ListWheelChildBuilderDelegate(
              builder: itemBuilder,
              childCount: childCount,
            ),
          ),
        ),
      ],
    );
  }
} 