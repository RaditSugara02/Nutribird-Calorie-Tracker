/// Macro Estimator - Auto-detect kategori makanan dan generate estimasi macro
///
/// Menyediakan:
/// - Category detection dari nama makanan
/// - Macro estimation berdasarkan kategori dan kalori
/// - Future-proof architecture untuk database lookup

/// Food Category enum
enum FoodCategory {
  PROTEIN_HEAVY, // Ayam, Daging, Ikan, Telur
  CARB_HEAVY, // Nasi, Roti, Pasta, Umbi
  FAT_HEAVY, // Minyak, Butter, Kacang, Biji
  MIXED, // Nasi Goreng, Pizza, dll
  BALANCED, // Buah, Sayur, Unknown
}

/// Macro estimation result
class MacroEstimation {
  final double protein;
  final double fat;
  final double carb;
  final FoodCategory category;

  MacroEstimation({
    required this.protein,
    required this.fat,
    required this.carb,
    required this.category,
  });
}

class MacroEstimator {
  /// Detect category dari nama makanan
  static FoodCategory detectCategory(String foodName) {
    final name = foodName.toLowerCase();

    // Check untuk kata kunci
    if (_containsKeywords(name, ['goreng', 'fried'])) {
      return FoodCategory.MIXED;
    }

    if (_containsKeywords(name, [
      'ayam',
      'daging',
      'ikan',
      'sapi',
      'kambing',
      'bebek',
      'chicken',
      'meat',
      'fish',
      'beef',
    ])) {
      return FoodCategory.PROTEIN_HEAVY;
    }

    if (_containsKeywords(name, [
      'nasi',
      'roti',
      'pasta',
      'mie',
      'bihun',
      'rice',
      'bread',
      'noodle',
    ])) {
      return FoodCategory.CARB_HEAVY;
    }

    if (_containsKeywords(name, ['telur', 'tahu', 'tempe', 'egg', 'tofu'])) {
      return FoodCategory.PROTEIN_HEAVY;
    }

    if (_containsKeywords(name, [
      'minyak',
      'butter',
      'margarin',
      'oil',
      'ghee',
    ])) {
      return FoodCategory.FAT_HEAVY;
    }

    if (_containsKeywords(name, [
      'kacang',
      'biji',
      'nut',
      'seed',
      'almond',
      'walnut',
    ])) {
      return FoodCategory.FAT_HEAVY;
    }

    if (_containsKeywords(name, [
      'buah',
      'sayur',
      'salad',
      'fruit',
      'vegetable',
    ])) {
      return FoodCategory.BALANCED;
    }

    // Default: BALANCED untuk unknown
    return FoodCategory.BALANCED;
  }

  /// Check jika nama mengandung keywords
  static bool _containsKeywords(String name, List<String> keywords) {
    return keywords.any((keyword) => name.contains(keyword));
  }

  /// Estimate macro berdasarkan kategori dan kalori
  static MacroEstimation estimateMacro(double kalori, FoodCategory category) {
    double protein, fat, carb;

    switch (category) {
      case FoodCategory.PROTEIN_HEAVY:
        // P 35%, L 40%, K 25%
        protein = (kalori * 0.35) / 4.0;
        fat = (kalori * 0.40) / 9.0;
        carb = (kalori * 0.25) / 4.0;
        break;

      case FoodCategory.CARB_HEAVY:
        // P 10%, L 10%, K 80%
        protein = (kalori * 0.10) / 4.0;
        fat = (kalori * 0.10) / 9.0;
        carb = (kalori * 0.80) / 4.0;
        break;

      case FoodCategory.FAT_HEAVY:
        // P 0%, L 100%, K 0%
        protein = 0.0;
        fat = kalori / 9.0;
        carb = 0.0;
        break;

      case FoodCategory.MIXED:
        // P 12%, L 30%, K 58%
        protein = (kalori * 0.12) / 4.0;
        fat = (kalori * 0.30) / 9.0;
        carb = (kalori * 0.58) / 4.0;
        break;

      case FoodCategory.BALANCED:
        // P 15%, L 20%, K 65%
        protein = (kalori * 0.15) / 4.0;
        fat = (kalori * 0.20) / 9.0;
        carb = (kalori * 0.65) / 4.0;
        break;
    }

    return MacroEstimation(
      protein: protein,
      fat: fat,
      carb: carb,
      category: category,
    );
  }

  /// Estimate macro dari nama makanan dan kalori
  static MacroEstimation estimateFromFoodName(String foodName, double kalori) {
    final category = detectCategory(foodName);
    return estimateMacro(kalori, category);
  }
}
