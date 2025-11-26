/// Add Custom Food State Model - Track state dan validation untuk add custom food screen
///
/// Menyediakan:
/// - Basic input tracking
/// - Estimated macro tracking
/// - User input tracking
/// - Validation status tracking
/// - Computed properties

import 'package:flutter_application_rpl_final/utils/macro_estimator.dart';
import 'package:flutter_application_rpl_final/utils/macro_validator.dart';
import 'package:flutter_application_rpl_final/utils/alert_message_factory.dart';

/// Validation status
enum ValidationStatus { initial, valid, warning, error }

/// Add Custom Food State
class AddCustomFoodState {
  // Basic Input
  String foodName;
  double kalori;
  FoodCategory detectedCategory;

  // Estimated Macro (auto-generated)
  double estimatedProtein;
  double estimatedFat;
  double estimatedCarb;

  // User Input (if edited)
  double? userProtein;
  double? userFat;
  double? userCarb;

  // Validation Status
  ValidationStatus validationStatus;
  List<AlertMessage> alerts;

  // User Action
  bool userAcceptedDefault; // Checkbox "Sudah sesuai?"
  bool userOverriddenValidation; // User click "Lanjut" despite warning

  AddCustomFoodState({
    this.foodName = '',
    this.kalori = 0.0,
    FoodCategory? detectedCategory,
    this.estimatedProtein = 0.0,
    this.estimatedFat = 0.0,
    this.estimatedCarb = 0.0,
    this.userProtein,
    this.userFat,
    this.userCarb,
    this.validationStatus = ValidationStatus.initial,
    List<AlertMessage>? alerts,
    this.userAcceptedDefault = true, // Default checked
    this.userOverriddenValidation = false,
  }) : detectedCategory = detectedCategory ?? FoodCategory.BALANCED,
       alerts = alerts ?? [];

  // Computed Properties (getters)
  double get activeProtein => userProtein ?? estimatedProtein;
  double get activeFat => userFat ?? estimatedFat;
  double get activeCarb => userCarb ?? estimatedCarb;

  double get macroKaloriTotal => MacroValidator.calculateKaloriFromMacro(
    activeProtein,
    activeFat,
    activeCarb,
  );

  bool get isConsistent {
    if (kalori == 0) return false;
    final ratio = macroKaloriTotal / kalori;
    return ratio >= 0.9 && ratio <= 1.1;
  }

  bool get isReadyToSubmit =>
      validationStatus == ValidationStatus.valid || userOverriddenValidation;

  // Methods
  void updateUserProtein(double value) {
    userProtein = value;
    validationStatus = ValidationStatus.initial; // Reset untuk re-validate
  }

  void updateUserFat(double value) {
    userFat = value;
    validationStatus = ValidationStatus.initial;
  }

  void updateUserCarb(double value) {
    userCarb = value;
    validationStatus = ValidationStatus.initial;
  }

  void acceptDefault() {
    userAcceptedDefault = true;
    clearUserEdits();
  }

  void rejectDefault() {
    userAcceptedDefault = false;
  }

  void clearUserEdits() {
    userProtein = null;
    userFat = null;
    userCarb = null;
    validationStatus = ValidationStatus.initial;
  }

  /// Validate current state - trigger full validation chain
  ValidationResult validateCurrent() {
    if (kalori <= 0) {
      return ValidationResult(
        isValid: false,
        violations: [
          MacroViolation(
            macroType: 'kalori',
            message: 'Kalori harus lebih dari 0',
            severity: ValidationSeverity.error,
          ),
        ],
        severity: ValidationSeverity.error,
      );
    }

    // 1. Hard limits check
    final hardLimitsResult = MacroValidator.validateHardLimits(
      activeProtein,
      activeFat,
      activeCarb,
      kalori,
    );

    if (!hardLimitsResult.isValid) {
      validationStatus = ValidationStatus.error;
      alerts = hardLimitsResult.violations.map((v) {
        return AlertMessage(
          severity: AlertMessageFactory.convertSeverity(v.severity),
          title: v.severity == ValidationSeverity.error
              ? 'Error'
              : 'Peringatan',
          message: v.message,
        );
      }).toList();
      return hardLimitsResult;
    }

    // 2. Consistency check
    final consistencyResult = MacroValidator.validateConsistency(
      activeProtein,
      activeFat,
      activeCarb,
      kalori,
    );

    if (!consistencyResult.isValid) {
      validationStatus = consistencyResult.severity == ValidationSeverity.error
          ? ValidationStatus.error
          : ValidationStatus.warning;
      alerts = consistencyResult.violations.map((v) {
        return AlertMessageFactory.generateConsistencyErrorMessage(
          macroKaloriTotal,
          kalori,
          ((macroKaloriTotal - kalori).abs() / kalori) * 100,
        );
      }).toList();
      return consistencyResult;
    }

    // 3. Realistic ratio check
    final ratioResult = MacroValidator.validateRealisticRatio(
      activeProtein,
      activeFat,
      activeCarb,
      kalori,
      detectedCategory,
    );

    if (!ratioResult.isRealistic) {
      validationStatus = ratioResult.severity == ValidationSeverity.error
          ? ValidationStatus.error
          : ValidationStatus.warning;
      alerts = ratioResult.flags.map((flag) {
        return AlertMessageFactory.generateRealisticRatioWarningMessage(
          flag.flagType,
          0.0, // Will be calculated in the method
          flag.suggestion ?? '',
          detectedCategory,
        );
      }).toList();
      return ValidationResult(
        isValid: false,
        violations: [],
        severity: ratioResult.severity,
      );
    }

    // 4. Special case check (zero macro)
    if (activeProtein == 0) {
      final zeroResult = MacroValidator.validateZeroMacro(
        'protein',
        detectedCategory,
      );
      if (!zeroResult.isValid &&
          zeroResult.severity == ValidationSeverity.warning) {
        validationStatus = ValidationStatus.warning;
        alerts.add(
          AlertMessageFactory.generateZeroMacroWarningMessage(
            'protein',
            detectedCategory,
            false,
          ),
        );
      }
    }

    if (activeFat == 0) {
      final zeroResult = MacroValidator.validateZeroMacro(
        'fat',
        detectedCategory,
      );
      if (!zeroResult.isValid &&
          zeroResult.severity == ValidationSeverity.warning) {
        validationStatus = ValidationStatus.warning;
        alerts.add(
          AlertMessageFactory.generateZeroMacroWarningMessage(
            'fat',
            detectedCategory,
            false,
          ),
        );
      }
    }

    if (activeCarb == 0) {
      final zeroResult = MacroValidator.validateZeroMacro(
        'carb',
        detectedCategory,
      );
      if (!zeroResult.isValid &&
          zeroResult.severity == ValidationSeverity.warning) {
        validationStatus = ValidationStatus.warning;
        alerts.add(
          AlertMessageFactory.generateZeroMacroWarningMessage(
            'carb',
            detectedCategory,
            false,
          ),
        );
      }
    }

    // All valid
    if (validationStatus != ValidationStatus.warning) {
      validationStatus = ValidationStatus.valid;
    }
    alerts = [];

    return ValidationResult(
      isValid: true,
      violations: [],
      severity: ValidationSeverity.info,
    );
  }

  /// Get alert untuk field tertentu
  AlertMessage? getAlertForField(String fieldName) {
    try {
      return alerts.firstWhere(
        (alert) =>
            alert.message.toLowerCase().contains(fieldName.toLowerCase()),
      );
    } catch (e) {
      return null; // No alert found
    }
  }

  /// Update estimasi macro dari nama dan kalori
  void updateEstimation(String name, double calories) {
    foodName = name;
    kalori = calories;

    if (name.isNotEmpty && calories > 0) {
      detectedCategory = MacroEstimator.detectCategory(name);
      final estimation = MacroEstimator.estimateMacro(
        calories,
        detectedCategory,
      );

      estimatedProtein = estimation.protein;
      estimatedFat = estimation.fat;
      estimatedCarb = estimation.carb;

      // Clear user edits jika user belum edit
      if (userAcceptedDefault) {
        clearUserEdits();
      }
    }
  }

  /// Copy state untuk immutability
  AddCustomFoodState copyWith({
    String? foodName,
    double? kalori,
    FoodCategory? detectedCategory,
    double? estimatedProtein,
    double? estimatedFat,
    double? estimatedCarb,
    double? userProtein,
    double? userFat,
    double? userCarb,
    ValidationStatus? validationStatus,
    List<AlertMessage>? alerts,
    bool? userAcceptedDefault,
    bool? userOverriddenValidation,
  }) {
    return AddCustomFoodState(
      foodName: foodName ?? this.foodName,
      kalori: kalori ?? this.kalori,
      detectedCategory: detectedCategory ?? this.detectedCategory,
      estimatedProtein: estimatedProtein ?? this.estimatedProtein,
      estimatedFat: estimatedFat ?? this.estimatedFat,
      estimatedCarb: estimatedCarb ?? this.estimatedCarb,
      userProtein: userProtein ?? this.userProtein,
      userFat: userFat ?? this.userFat,
      userCarb: userCarb ?? this.userCarb,
      validationStatus: validationStatus ?? this.validationStatus,
      alerts: alerts ?? this.alerts,
      userAcceptedDefault: userAcceptedDefault ?? this.userAcceptedDefault,
      userOverriddenValidation:
          userOverriddenValidation ?? this.userOverriddenValidation,
    );
  }
}
