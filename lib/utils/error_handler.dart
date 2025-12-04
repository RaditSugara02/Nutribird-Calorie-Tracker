import 'package:flutter/material.dart';
import 'package:flutter_application_rpl_final/utils/logger.dart';

/// Centralized error handler untuk aplikasi
class ErrorHandler {
  /// Handle error dan tampilkan user-friendly message
  static void handleError(
    BuildContext? context,
    dynamic error,
    StackTrace? stackTrace, {
    String? customMessage,
    VoidCallback? onRetry,
  }) {
    // Log error
    AppLogger.error(
      customMessage ?? 'Terjadi kesalahan',
      error,
      stackTrace,
    );
    
    // Show user-friendly error message
    if (context != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            customMessage ?? 'Terjadi kesalahan. Silakan coba lagi.',
          ),
          backgroundColor: Colors.redAccent,
          duration: const Duration(seconds: 4),
          action: onRetry != null
              ? SnackBarAction(
                  label: 'Coba Lagi',
                  textColor: Colors.white,
                  onPressed: onRetry,
                )
              : null,
        ),
      );
    }
  }
  
  /// Handle error dengan dialog (untuk error kritis)
  static Future<void> showErrorDialog(
    BuildContext context,
    String title,
    String message, {
    String? buttonText,
    VoidCallback? onConfirm,
  }) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1D362C),
          title: Text(
            title,
            style: const TextStyle(
              color: Colors.redAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            message,
            style: const TextStyle(color: Color(0xFFA2F46E)),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onConfirm?.call();
              },
              child: Text(
                buttonText ?? 'OK',
                style: const TextStyle(color: Color(0xFFA2F46E)),
              ),
            ),
          ],
        );
      },
    );
  }
  
  /// Handle network/storage errors dengan retry mechanism
  static Future<T?> withRetry<T>({
    required Future<T> Function() operation,
    int maxRetries = 3,
    Duration delay = const Duration(seconds: 1),
    String? errorMessage,
  }) async {
    int attempts = 0;
    
    while (attempts < maxRetries) {
      try {
        return await operation();
      } catch (e, stackTrace) {
        attempts++;
        AppLogger.warning(
          'Attempt $attempts/$maxRetries failed: ${errorMessage ?? e.toString()}',
          e,
          stackTrace,
        );
        
        if (attempts >= maxRetries) {
          AppLogger.error(
            'Max retries reached: ${errorMessage ?? e.toString()}',
            e,
            stackTrace,
          );
          rethrow;
        }
        
        // Wait before retry
        await Future.delayed(delay);
      }
    }
    
    return null;
  }
}

