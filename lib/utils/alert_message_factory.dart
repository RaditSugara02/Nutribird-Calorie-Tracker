/// Alert Message Factory - Generate alert messages dengan format konsisten
///
/// Menyediakan:
/// - Consistency error messages
/// - Hard limit violation messages
/// - Realistic ratio warning messages
/// - Zero macro warning messages
/// - Category not found messages

import 'package:flutter/material.dart';
import 'package:flutter_application_rpl_final/utils/macro_estimator.dart';
import 'package:flutter_application_rpl_final/utils/macro_validator.dart';

/// Alert severity
enum AlertSeverity { info, warning, error }

/// Alert message
class AlertMessage {
  final AlertSeverity severity;
  final String title;
  final String message;
  final List<ActionButton> actionButtons;

  AlertMessage({
    required this.severity,
    required this.title,
    required this.message,
    this.actionButtons = const [],
  });
}

/// Action button untuk alert
class ActionButton {
  final String text;
  final VoidCallback? onPressed;
  final bool isDestructive;

  ActionButton({
    required this.text,
    this.onPressed,
    this.isDestructive = false,
  });
}

class AlertMessageFactory {
  /// Generate consistency error message
  static AlertMessage generateConsistencyErrorMessage(
    double macroKal,
    double inputKal,
    double percent,
  ) {
    final diff = (macroKal - inputKal).abs();

    if (percent < 5) {
      return AlertMessage(
        severity: AlertSeverity.info,
        title: 'Info',
        message:
            'ℹ️ Macro Anda total ${macroKal.toStringAsFixed(0)} kcal, input ${inputKal.toStringAsFixed(0)} kcal. Selisih ${diff.toStringAsFixed(0)} kcal (${percent.toStringAsFixed(1)}%).',
      );
    } else if (percent <= 15) {
      return AlertMessage(
        severity: AlertSeverity.warning,
        title: 'Peringatan',
        message:
            '⚠️ Macro Anda total ${macroKal.toStringAsFixed(0)} kcal, tapi Anda input ${inputKal.toStringAsFixed(0)} kcal. Selisih ${diff.toStringAsFixed(0)} kcal (${percent.toStringAsFixed(1)}%).',
        actionButtons: [
          ActionButton(text: 'Tidak', isDestructive: false),
          ActionButton(text: 'Lanjut', isDestructive: false),
        ],
      );
    } else {
      return AlertMessage(
        severity: AlertSeverity.error,
        title: 'Error',
        message:
            '❌ Macro Anda total ${macroKal.toStringAsFixed(0)} kcal, tapi Anda input ${inputKal.toStringAsFixed(0)} kcal. Selisih ${diff.toStringAsFixed(0)} kcal (${percent.toStringAsFixed(1)}%). Silakan edit macro.',
        actionButtons: [ActionButton(text: 'Batal Edit', isDestructive: false)],
      );
    }
  }

  /// Generate hard limit violation message
  static AlertMessage generateHardLimitViolationMessage(
    String macro,
    double value,
    double min,
    double max,
    double kalori,
  ) {
    final midpoint = (min + max) / 2;
    final macroName = macro == 'protein'
        ? 'Protein'
        : macro == 'fat'
        ? 'Lemak'
        : 'Karbohidrat';

    return AlertMessage(
      severity: AlertSeverity.error,
      title: 'Error',
      message:
          '❌ $macroName ${value.toStringAsFixed(1)}g di luar range ${min.toStringAsFixed(1)}g - ${max.toStringAsFixed(1)}g untuk ${kalori.toStringAsFixed(0)} kcal. Saran: ${midpoint.toStringAsFixed(1)}g',
      actionButtons: [ActionButton(text: 'Edit', isDestructive: false)],
    );
  }

  /// Generate realistic ratio warning message
  static AlertMessage generateRealisticRatioWarningMessage(
    String flagType,
    double percent,
    String expected,
    FoodCategory category,
  ) {
    final categoryName = category.toString().split('.').last;
    final macroName = flagType.contains('protein')
        ? 'Protein'
        : flagType.contains('fat')
        ? 'Lemak'
        : 'Karbohidrat';

    return AlertMessage(
      severity: AlertSeverity.warning,
      title: 'Peringatan',
      message:
          '⚠️ Anda input ${percent.toStringAsFixed(1)}% $macroName untuk "$categoryName". Biasanya $expected. Cek lagi?',
      actionButtons: [
        ActionButton(text: 'Batal Edit', isDestructive: false),
        ActionButton(text: 'Review', isDestructive: false),
      ],
    );
  }

  /// Generate zero macro warning message
  static AlertMessage generateZeroMacroWarningMessage(
    String macro,
    FoodCategory category,
    bool isAllowed,
  ) {
    final categoryName = category.toString().split('.').last;
    final macroName = macro == 'protein'
        ? 'Protein'
        : macro == 'fat'
        ? 'Lemak'
        : 'Karbohidrat';

    if (isAllowed) {
      return AlertMessage(
        severity: AlertSeverity.info,
        title: 'Info',
        message: 'ℹ️ Makanan tanpa $macroName untuk $categoryName - OK',
      );
    } else {
      return AlertMessage(
        severity: AlertSeverity.warning,
        title: 'Peringatan',
        message: '⚠️ $macroName 0g tidak realistis untuk $categoryName. Yakin?',
        actionButtons: [
          ActionButton(text: 'Batal', isDestructive: false),
          ActionButton(text: 'Yakin', isDestructive: false),
        ],
      );
    }
  }

  /// Generate category not found message
  static AlertMessage generateCategoryNotFoundMessage(String foodName) {
    return AlertMessage(
      severity: AlertSeverity.info,
      title: 'Info',
      message:
          'ℹ️ Kategori "$foodName" tidak terdeteksi. Menggunakan estimasi balanced. Edit jika perlu.',
    );
  }

  /// Convert ValidationSeverity ke AlertSeverity
  static AlertSeverity convertSeverity(ValidationSeverity severity) {
    switch (severity) {
      case ValidationSeverity.info:
        return AlertSeverity.info;
      case ValidationSeverity.warning:
        return AlertSeverity.warning;
      case ValidationSeverity.error:
        return AlertSeverity.error;
    }
  }
}
