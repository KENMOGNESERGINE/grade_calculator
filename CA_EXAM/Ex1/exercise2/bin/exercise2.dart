// 1. The Logger interface
abstract interface class Logger {
  void log(String message);
}

// 2a. ConsoleLogger — prints to console
class ConsoleLogger implements Logger {
  @override
  void log(String message) {
    print(message);
  }
}

// 2b. FileLogger — simulates writing to a file
class FileLogger implements Logger {
  @override
  void log(String message) {
    print("File:  $message");
  }
}

// 3. Application DELEGATES logging to a Logger
class Application {
  final Logger _logger;

  Application(this._logger);

  void run() {
    _logger.log("Application started");
    _logger.log("Processing data...");
    _logger.log("Application finished");
  }
}

void main() {
  print("=== Using ConsoleLogger ===");
  final consoleApp = Application(ConsoleLogger());
  consoleApp.run();

  print("\n=== Using FileLogger ===");
  final fileApp = Application(FileLogger());
  fileApp.run();
}