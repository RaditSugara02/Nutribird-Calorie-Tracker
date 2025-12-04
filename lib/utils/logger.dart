/// Simple logging utility untuk mengganti print() statements
/// Support untuk different log levels dan bisa di-disable di production
class AppLogger {
  static bool _isDebugMode = true; // Set to false in production
  
  /// Set debug mode (call this in main.dart)
  static void setDebugMode(bool enabled) {
    _isDebugMode = enabled;
  }
  
  /// Debug level - hanya muncul di debug mode
  static void debug(String message, [Object? error, StackTrace? stackTrace]) {
    if (_isDebugMode) {
      _log('DEBUG', message, error, stackTrace);
    }
  }
  
  /// Info level - informasi umum
  static void info(String message, [Object? error, StackTrace? stackTrace]) {
    _log('INFO', message, error, stackTrace);
  }
  
  /// Warning level - peringatan
  static void warning(String message, [Object? error, StackTrace? stackTrace]) {
    _log('WARNING', message, error, stackTrace);
  }
  
  /// Error level - error yang perlu diperhatikan
  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    _log('ERROR', message, error, stackTrace);
  }
  
  /// Internal logging method
  static void _log(String level, String message, Object? error, StackTrace? stackTrace) {
    final timestamp = DateTime.now().toIso8601String();
    final logMessage = '[$timestamp] [$level] $message';
    
    // In production, bisa diarahkan ke crash reporting service
    print(logMessage);
    
    if (error != null) {
      print('Error details: $error');
    }
    
    if (stackTrace != null && _isDebugMode) {
      print('Stack trace: $stackTrace');
    }
  }
}

