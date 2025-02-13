import 'dart:io';
import 'api_service.dart';

Future<void> main() async {
  // Port server lokal
  const int port = 443;

  try {
    // Menjalankan server
    print('🚀 Starting server on https://api.deteksicampak.my.id:$port ...');
    await serve(port);
    print('✅ Server running at https://api.deteksicampak.my.id:$port');

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
