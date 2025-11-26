/// Macro Validator - Validasi konsistensi dan hard limits untuk macro nutrients
///
/// Menyediakan:
/// - Hard limits validation (min/max per macro)
/// - Consistency check (kalori vs macro)
/// - Realistic ratio validation per kategori
/// - Special case handlers (0g macro, unknown category)

import 'package:flutter_application_rpl_final/utils/macro_estimator.dart';

/// Constants untuk kalori per gram macro
class MacroConstants {
  static const double PROTEIN_KCAL_PER_GRAM = 4.0;
  static const double FAT_KCAL_PER_GRAM = 9.0;
  static const double CARB_KCAL_PER_GRAM = 4.0;

  // Max realistic limits per 300 kcal (untuk reference)
  static const double MAX_PROTEIN_PER_300KCAL = 75.0; // ~0.25g per kcal
  static const double MAX_FAT_PER_300KCAL = 35.0; // ~0.12g per kcal
  static const double MAX_CARB_PER_300KCAL = 75.0; // ~0.25g per kcal
}

/// Result dari validation
class ValidationResult {
  final bool isValid;
  final List<MacroViolation> violations;
  final ValidationSeverity severity;

  ValidationResult({
    required this.isValid,
    required this.violations,
    required this.severity,
  });
}

/// Violation detail
class MacroViolation {
  final String macroType; // 'protein', 'fat', 'carb', 'consistency'
  final String message;
  final double? actualValue;
  final double? minValue;
  final double? maxValue;
  final ValidationSeverity severity;

  MacroViolation({
    required this.macroType,
    required this.message,
    this.actualValue,
    this.minValue,
    this.maxValue,
    required this.severity,
  });
}

/// Validation severity
enum ValidationSeverity { info, warning, error }

/// Ratio validation result
class RatioValidationResult {
  final bool isRealistic;
  final List<RatioFlag> flags;
  final ValidationSeverity severity;

  RatioValidationResult({
    required this.isRealistic,
    required this.flags,
    required this.severity,
  });
}

/// Ratio flag detail
class RatioFlag {
  final String flagType; // 'protein_low', 'fat_high', etc.
  final String message;
  final String? suggestion;

  RatioFlag({required this.flagType, required this.message, this.suggestion});
}

class MacroValidator {
  /// Calculate hard limit minimum untuk macro tertentu
  static double calculateHardLimitMin(String macro, double kalori) {
    switch (macro.toLowerCase()) {
      case 'protein':
        return (kalori / 200).clamp(0.0, double.infinity);
      case 'fat':
        return (kalori / 1800).clamp(0.0, double.infinity);
      case 'carb':
        return (kalori / 400).clamp(0.0, double.infinity);
      default:
        return 0.0;
    }
  }

  /// Calculate hard limit maximum untuk macro tertentu
  static double calculateHardLimitMax(String macro, double kalori) {
    switch (macro.toLowerCase()) {
      case 'protein':
        return (kalori / MacroConstants.PROTEIN_KCAL_PER_GRAM).clamp(
          0.0,
          999.0,
        );
      case 'fat':
        return (kalori / MacroConstants.FAT_KCAL_PER_GRAM).clamp(0.0, 999.0);
      case 'carb':
        return (kalori / MacroConstants.CARB_KCAL_PER_GRAM).clamp(0.0, 999.0);
      default:
        return 999.0;
    }
  }

  /// Validate hard limits untuk semua macro
  static ValidationResult validateHardLimits(
    double protein,
    double fat,
    double carb,
    double kalori,
  ) {
    List<MacroViolation> violations = [];
    ValidationSeverity maxSeverity = ValidationSeverity.info;

    // Validate protein
    final proteinMin = calculateHardLimitMin('protein', kalori);
    final proteinMax = calculateHardLimitMax('protein', kalori);
    if (protein < proteinMin || protein > proteinMax) {
      violations.add(
        MacroViolation(
          macroType: 'protein',
          message:
              'Protein ${protein}g di luar range ${proteinMin.toStringAsFixed(1)}g - ${proteinMax.toStringAsFixed(1)}g untuk ${kalori.toStringAsFixed(0)} kcal',
          actualValue: protein,
          minValue: proteinMin,
          maxValue: proteinMax,
          severity: ValidationSeverity.error,
        ),
      );
      maxSeverity = ValidationSeverity.error;
    }

    // Validate fat
    final fatMin = calculateHardLimitMin('fat', kalori);
    final fatMax = calculateHardLimitMax('fat', kalori);
    if (fat < fatMin || fat > fatMax) {
      violations.add(
        MacroViolation(
          macroType: 'fat',
          message:
              'Lemak ${fat}g di luar range ${fatMin.toStringAsFixed(1)}g - ${fatMax.toStringAsFixed(1)}g untuk ${kalori.toStringAsFixed(0)} kcal',
          actualValue: fat,
          minValue: fatMin,
          maxValue: fatMax,
          severity: ValidationSeverity.error,
        ),
      );
      maxSeverity = ValidationSeverity.error;
    }

    // Validate carb
    final carbMin = calculateHardLimitMin('carb', kalori);
    final carbMax = calculateHardLimitMax('carb', kalori);
    if (carb < carbMin || carb > carbMax) {
      violations.add(
        MacroViolation(
          macroType: 'carb',
          message:
              'Karbohidrat ${carb}g di luar range ${carbMin.toStringAsFixed(1)}g - ${carbMax.toStringAsFixed(1)}g untuk ${kalori.toStringAsFixed(0)} kcal',
          actualValue: carb,
          minValue: carbMin,
          maxValue: carbMax,
          severity: ValidationSeverity.error,
        ),
      );
      maxSeverity = ValidationSeverity.error;
    }

    return ValidationResult(
      isValid: violations.isEmpty,
      violations: violations,
      severity: maxSeverity,
    );
  }

  /// Calculate total kalori dari macro
  static double calculateKaloriFromMacro(
    double protein,
    double fat,
    double carb,
  ) {
    return (protein * MacroConstants.PROTEIN_KCAL_PER_GRAM) +
        (fat * MacroConstants.FAT_KCAL_PER_GRAM) +
        (carb * MacroConstants.CARB_KCAL_PER_GRAM);
  }

  /// Validate consistency antara kalori input dan kalori dari macro
  static ValidationResult validateConsistency(
    double protein,
    double fat,
    double carb,
    double inputKalori,
  ) {
    final macroKalori = calculateKaloriFromMacro(protein, fat, carb);
    final diff = (macroKalori - inputKalori).abs();
    final percent = (diff / inputKalori) * 100;

    ValidationSeverity severity;
    String message;

    if (percent < 5) {
      severity = ValidationSeverity.info;
      message =
          'Macro Anda total ${macroKalori.toStringAsFixed(0)} kcal, input ${inputKalori.toStringAsFixed(0)} kcal. Selisih ${diff.toStringAsFixed(0)} kcal (${percent.toStringAsFixed(1)}%).';
    } else if (percent <= 15) {
      severity = ValidationSeverity.warning;
      message =
          'Macro Anda total ${macroKalori.toStringAsFixed(0)} kcal, tapi Anda input ${inputKalori.toStringAsFixed(0)} kcal. Selisih ${diff.toStringAsFixed(0)} kcal (${percent.toStringAsFixed(1)}%).';
    } else {
      severity = ValidationSeverity.error;
      message =
          'Macro Anda total ${macroKalori.toStringAsFixed(0)} kcal, tapi Anda input ${inputKalori.toStringAsFixed(0)} kcal. Selisih ${diff.toStringAsFixed(0)} kcal (${percent.toStringAsFixed(1)}%). Silakan edit macro.';
    }

    return ValidationResult(
      isValid: percent < 15,
      violations: [
        MacroViolation(
          macroType: 'consistency',
          message: message,
          actualValue: macroKalori,
          severity: severity,
        ),
      ],
      severity: severity,
    );
  }

  /// Calculate ratio percentage untuk macro
  static double calculateRatioPercent(
    double macro,
    double totalKalori,
    double ratioPerGram,
  ) {
    if (totalKalori == 0) return 0.0;
    final macroKalori = macro * ratioPerGram;
    return (macroKalori / totalKalori) * 100;
  }

  /// Validate realistic ratio berdasarkan kategori makanan
  static RatioValidationResult validateRealisticRatio(
    double protein,
    double fat,
    double carb,
    double kalori,
    FoodCategory category,
  ) {
    final proteinPercent = calculateRatioPercent(
      protein,
      kalori,
      MacroConstants.PROTEIN_KCAL_PER_GRAM,
    );
    final fatPercent = calculateRatioPercent(
      fat,
      kalori,
      MacroConstants.FAT_KCAL_PER_GRAM,
    );
    final carbPercent = calculateRatioPercent(
      carb,
      kalori,
      MacroConstants.CARB_KCAL_PER_GRAM,
    );

    List<RatioFlag> flags = [];
    ValidationSeverity maxSeverity = ValidationSeverity.info;

    // Get expected ranges untuk kategori
    final ranges = _getCategoryRanges(category);

    // Check protein
    if (proteinPercent < ranges['proteinMin']! ||
        proteinPercent > ranges['proteinMax']!) {
      final flag = _createRatioFlag(
        'protein',
        proteinPercent,
        ranges['proteinMin']!,
        ranges['proteinMax']!,
        category,
      );
      flags.add(flag);
      if (flag.message.contains('⚠️')) {
        maxSeverity = ValidationSeverity.warning;
      }
    }

    // Check fat
    if (fatPercent < ranges['fatMin']! || fatPercent > ranges['fatMax']!) {
      final flag = _createRatioFlag(
        'fat',
        fatPercent,
        ranges['fatMin']!,
        ranges['fatMax']!,
        category,
      );
      flags.add(flag);
      if (flag.message.contains('⚠️')) {
        maxSeverity = ValidationSeverity.warning;
      }
    }

    // Check carb
    if (carbPercent < ranges['carbMin']! || carbPercent > ranges['carbMax']!) {
      final flag = _createRatioFlag(
        'carb',
        carbPercent,
        ranges['carbMin']!,
        ranges['carbMax']!,
        category,
      );
      flags.add(flag);
      if (flag.message.contains('⚠️')) {
        maxSeverity = ValidationSeverity.warning;
      }
    }

    return RatioValidationResult(
      isRealistic: flags.isEmpty,
      flags: flags,
      severity: maxSeverity,
    );
  }

  /// Get expected ranges untuk kategori
  static Map<String, double> _getCategoryRanges(FoodCategory category) {
    switch (category) {
      case FoodCategory.PROTEIN_HEAVY:
        return {
          'proteinMin': 30.0,
          'proteinMax': 50.0,
          'fatMin': 20.0,
          'fatMax': 40.0,
          'carbMin': 10.0,
          'carbMax': 30.0,
        };
      case FoodCategory.CARB_HEAVY:
        return {
          'proteinMin': 5.0,
          'proteinMax': 15.0,
          'fatMin': 5.0,
          'fatMax': 20.0,
          'carbMin': 65.0,
          'carbMax': 85.0,
        };
      case FoodCategory.FAT_HEAVY:
        return {
          'proteinMin': 0.0,
          'proteinMax': 20.0,
          'fatMin': 60.0,
          'fatMax': 100.0,
          'carbMin': 0.0,
          'carbMax': 20.0,
        };
      case FoodCategory.MIXED:
        return {
          'proteinMin': 15.0,
          'proteinMax': 25.0,
          'fatMin': 15.0,
          'fatMax': 30.0,
          'carbMin': 50.0,
          'carbMax': 70.0,
        };
      case FoodCategory.BALANCED:
        return {
          'proteinMin': 10.0,
          'proteinMax': 25.0,
          'fatMin': 10.0,
          'fatMax': 30.0,
          'carbMin': 50.0,
          'carbMax': 75.0,
        };
    }
  }

  /// Create ratio flag
  static RatioFlag _createRatioFlag(
    String macroType,
    double actualPercent,
    double minPercent,
    double maxPercent,
    FoodCategory category,
  ) {
    final categoryName = category.toString().split('.').last;
    final expected = '$minPercent-${maxPercent}%';
    final suggestion = 'Biasanya $expected untuk kategori $categoryName';

    String message;
    if (actualPercent < minPercent) {
      message =
          '⚠️ Anda input ${actualPercent.toStringAsFixed(1)}% ${macroType} untuk "$categoryName". $suggestion. Cek lagi?';
    } else {
      message =
          '⚠️ Anda input ${actualPercent.toStringAsFixed(1)}% ${macroType} untuk "$categoryName". $suggestion. Cek lagi?';
    }

    return RatioFlag(
      flagType: '${macroType}_out_of_range',
      message: message,
      suggestion: suggestion,
    );
  }

  /// Validate zero macro - allow/block berdasarkan kategori
  static ValidationResult validateZeroMacro(
    String macro,
    FoodCategory category,
  ) {
    bool isAllowed = false;
    String message;

    switch (macro.toLowerCase()) {
      case 'protein':
        isAllowed =
            category == FoodCategory.CARB_HEAVY ||
            category == FoodCategory.FAT_HEAVY;
        message = isAllowed
            ? 'Makanan tanpa protein untuk ${category.toString().split('.').last} - OK'
            : '⚠️ Protein 0g tidak realistis untuk ${category.toString().split('.').last}. Yakin?';
        break;
      case 'fat':
        isAllowed =
            category == FoodCategory.CARB_HEAVY ||
            category == FoodCategory.PROTEIN_HEAVY;
        message = isAllowed
            ? 'Makanan tanpa lemak untuk ${category.toString().split('.').last} - OK'
            : '⚠️ Lemak 0g tidak realistis untuk ${category.toString().split('.').last}. Yakin?';
        break;
      case 'carb':
        isAllowed =
            category == FoodCategory.PROTEIN_HEAVY ||
            category == FoodCategory.FAT_HEAVY;
        message = isAllowed
            ? 'Makanan tanpa karbohidrat untuk ${category.toString().split('.').last} - OK'
            : '⚠️ Karbohidrat 0g tidak realistis untuk ${category.toString().split('.').last}. Yakin?';
        break;
      default:
        isAllowed = false;
        message = 'Macro tidak valid';
    }

    return ValidationResult(
      isValid: isAllowed,
      violations: [
        MacroViolation(
          macroType: macro,
          message: message,
          severity: isAllowed
              ? ValidationSeverity.info
              : ValidationSeverity.warning,
        ),
      ],
      severity: isAllowed
          ? ValidationSeverity.info
          : ValidationSeverity.warning,
    );
  }

  /// Detect unconventional diet
  static Map<String, dynamic> detectUnconventionalDiet(
    double protein,
    double fat,
    double carb,
    double kalori,
  ) {
    final proteinPercent = calculateRatioPercent(
      protein,
      kalori,
      MacroConstants.PROTEIN_KCAL_PER_GRAM,
    );
    final fatPercent = calculateRatioPercent(
      fat,
      kalori,
      MacroConstants.FAT_KCAL_PER_GRAM,
    );
    final carbPercent = calculateRatioPercent(
      carb,
      kalori,
      MacroConstants.CARB_KCAL_PER_GRAM,
    );

    // Keto: High fat (70%+), Low carb (<10%)
    if (fatPercent >= 70 && carbPercent < 10) {
      return {'isUnconventional': true, 'dietType': 'keto'};
    }

    // High protein: Protein > 40%
    if (proteinPercent > 40) {
      return {'isUnconventional': true, 'dietType': 'high-protein'};
    }

    // Low fat: Fat < 10%
    if (fatPercent < 10 && carbPercent > 70) {
      return {'isUnconventional': true, 'dietType': 'low-fat'};
    }

    return {'isUnconventional': false, 'dietType': null};
  }

  /// Handle unknown category - return balanced ratio
  static Map<String, dynamic> handleUnknownCategory(double kalori) {
    // Use BALANCED ratio: P 15%, L 20%, K 65%
    final proteinPercent = 0.15;
    final fatPercent = 0.20;
    final carbPercent = 0.65;

    final estimatedProtein =
        (kalori * proteinPercent) / MacroConstants.PROTEIN_KCAL_PER_GRAM;
    final estimatedFat =
        (kalori * fatPercent) / MacroConstants.FAT_KCAL_PER_GRAM;
    final estimatedCarb =
        (kalori * carbPercent) / MacroConstants.CARB_KCAL_PER_GRAM;

    return {
      'estimatedProtein': estimatedProtein,
      'estimatedFat': estimatedFat,
      'estimatedCarb': estimatedCarb,
      'category': FoodCategory.BALANCED,
    };
  }
}
