/// Constants untuk aplikasi Calorie Tracker
class AppConstants {
  // Colors
  static const int darkGreenBgValue = 0xFF1D362C;
  static const int lightGreenTextValue = 0xFFA2F46E;
  static const int darkTextValue = 0xFF112D21;

  // Meal Types
  static const List<String> mealTypes = [
    'Sarapan',
    'Makan Siang',
    'Makan Malam',
    'Cemilan',
  ];

  // Weight Limits
  static const double minWeight = 20.0; // kg
  static const double maxWeight = 200.0; // kg

  // Height Limits
  static const double minHeight = 100.0; // cm
  static const double maxHeight = 250.0; // cm

  // Age Limits
  static const int minAge = 15;
  static const int maxAge = 80;

  // Image Quality
  static const int imageQuality = 85;

  // Debounce Duration
  static const Duration debounceDuration = Duration(milliseconds: 500);

  // Animation Duration
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 300);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);

  // SnackBar Duration
  static const Duration snackBarShortDuration = Duration(seconds: 2);
  static const Duration snackBarMediumDuration = Duration(seconds: 3);
  static const Duration snackBarLongDuration = Duration(seconds: 4);

  // List Performance
  static const double listItemExtent = 60.0; // Height untuk ListView.builder optimization
}

