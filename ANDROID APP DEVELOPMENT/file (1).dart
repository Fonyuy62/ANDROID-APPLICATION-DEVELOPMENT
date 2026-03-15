// 1. Define the Logger interface (abstract class in Dart)
abstract interface class Logger {
  void log(String message);
}

// 2a. ConsoleLogger implementation
class ConsoleLogger implements Logger {
  @override
  void log(String message) {
    print("[Console] $message");
  }
}

// 2b. FileLogger implementation (simulated)
class FileLogger implements Logger {
  @override
  void log(String message) {
    print("File: $message");
  }
}

// 3. Application class — delegates logging via composition (Dart's way)
class Application implements Logger {
  final Logger _logger;

  Application(this._logger);

  @override
  void log(String message) => _logger.log(message);

  void run() {
    log("Application started");
    log("Processing data...");
    log("Application finished");
  }
}

void main() {
  print("--- Using ConsoleLogger ---");
  final consoleApp = Application(ConsoleLogger());
  consoleApp.run();

  print("\n--- Using FileLogger ---");
  final fileApp = Application(FileLogger());
  fileApp.run();
}
