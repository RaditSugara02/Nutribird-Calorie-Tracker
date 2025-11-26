/// Nutrition Data Source - Abstract class untuk future-proofing database lookup
/// 
/// Menyediakan:
/// - Abstract interface untuk nutrition data lookup
/// - Local implementation untuk MVP
/// - Architecture untuk remote API/database di masa depan

import 'package:flutter_application_rpl_final/utils/macro_estimator.dart';

/// Nutrition data dari source
class NutritionData {
  final String foodName;
  final double protein;
  final double fat;
  final double carb;
  final int calories;
  final FoodCategory? category;
  
  NutritionData({
    required this.foodName,
    required this.protein,
    required this.fat,
    required this.carb,
    required this.calories,
    this.category,
  });
}

/// Abstract class untuk nutrition data source
abstract class NutritionDataSource {
  /// Lookup nutrition data dari food name
  Future<NutritionData?> lookup(String foodName);
}

/// Local nutrition data source (hardcoded untuk MVP)
class LocalNutritionDataSource implements NutritionDataSource {
  // Hardcoded data untuk makanan umum (bisa di-expand)
  final Map<String, NutritionData> _localData = {
    'nasi putih': NutritionData(
      foodName: 'Nasi Putih',
      protein: 4.0,
      fat: 0.5,
      carb: 45.0,
      calories: 200,
      category: FoodCategory.CARB_HEAVY,
    ),
    'ayam goreng': NutritionData(
      foodName: 'Ayam Goreng',
      protein: 30.0,
      fat: 20.0,
      carb: 0.0,
      calories: 300,
      category: FoodCategory.PROTEIN_HEAVY,
    ),
    // Bisa ditambahkan lebih banyak data di sini
  };
  
  @override
  Future<NutritionData?> lookup(String foodName) async {
    // Simulate async operation
    await Future.delayed(const Duration(milliseconds: 50));
    
    final normalizedName = foodName.toLowerCase().trim();
    return _localData[normalizedName];
  }
}

/// Remote nutrition data source (untuk future API integration)
class RemoteNutritionDataSource implements NutritionDataSource {
  // TODO: Implement API call untuk nutrition database
  // Contoh: USDA Food Data Central API, Nutritionix API, dll
  
  @override
  Future<NutritionData?> lookup(String foodName) async {
    // Placeholder untuk future implementation
    // throw UnimplementedError('RemoteNutritionDataSource not implemented yet');
    return null; // Return null untuk fallback ke estimation
  }
}

