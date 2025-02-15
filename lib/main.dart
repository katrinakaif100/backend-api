import 'dart:io';
import 'package:backend_api/api_service.dart';

Future<void> main() async {
  final corsOrigin = Platform.environment['CORS_ORIGIN'] ?? '*';
  print('CORS_ORIGIN dari environment: $corsOrigin');
  // Gunakan port dari environment (Vercel) atau default ke 8080 jika lokal
  final int port = int.tryParse(Platform.environment['PORT'] ?? '8080') ?? 8080;

  // Jalankan server dengan handler dari api_service.dart
  try {
    print('🚀 Starting server on port $port...');
    await serve(port);
    print('✅ Server running on port $port');

    // Menangani shutdown server saat menerima sinyal SIGINT (Ctrl+C)
    ProcessSignal.sigint.watch().listen((signal) async {
      print('\n🛑 Server shutting down...');
      exit(0);
    });
  } catch (e, stackTrace) {
    // Log error jika server gagal dijalankan
    print('❌ Failed to start server: $e');
    print('StackTrace: $stackTrace');
    exit(1);
  }
}
