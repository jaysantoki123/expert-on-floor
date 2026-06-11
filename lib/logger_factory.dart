import 'package:logger/logger.dart';

class AppLogger {
  /// Creates and returns a brand-new Logger instance every time it's called.
  /// You can optionally pass a [topic] or class name to identify where the logs are coming from.
  static Logger create({String? topic}) {
    return Logger(
      printer: PrettyPrinter(
        methodCount: 1, // Reduced to 1 for cleaner sequential logs
        errorMethodCount: 5,
        lineLength: 80,
        colors: true, // Enables colorful terminal outputs
        printEmojis: true,
        printTime: false, // Turn off default time if you want less clutter
      ),
      // The topic adds a custom tag (e.g., [AuthService]) to the top of this specific logger instance
    );
  }
}
