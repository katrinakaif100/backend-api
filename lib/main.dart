import 'dart:io';
import 'api_service.dart' as api;

Future<void> main() async {
  // Validasi apakah port tersedia
  final port = int.tryParse(Platform.environment['PORT'] ?? '8080') ?? 8080;

  try {
    // Menjalankan server
    await api.serve(port);
    print('✅ Server running at http://192.168.0.140:$port');
    print('Press Ctrl+C to stop the server.');

    // Menangani SIGINT (Ctrl+C) untuk shutdown server
    ProcessSignal.sigint.watch().listen((signal) async {
      print('\n🛑 Server shutting down...');
      exit(0);
    });
  } catch (e, stackTrace) {
    // Menangani error dengan log lebih detail
    print('❌ Failed to start server: $e');
    print('StackTrace: $stackTrace');
    exit(1);
  }
}
