import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:cryptography/cryptography.dart';

// Inisialisasi penyimpanan
final FlutterSecureStorage secureStorage = FlutterSecureStorage();
String? encryptedCredentials;

// Fungsi enkripsi (khusus backend)
Future<String> encryptData(String data) async {
  final algorithm = AesGcm.with256bits();
  final secretKey = await algorithm.newSecretKey();
  final nonce = algorithm.newNonce();

  final encrypted = await algorithm.encrypt(
    utf8.encode(data),
    secretKey: secretKey,
    nonce: nonce,
  );

  return base64Encode(encrypted.concatenation());
}

// Fungsi menyimpan kredensial
Future<void> saveCredentials(String username, String password) async {
  String rawData = jsonEncode({'username': username, 'password': password});

  if (Platform.isAndroid || Platform.isIOS) {
    // Gunakan Secure Storage di Flutter Mobile
    await secureStorage.write(key: 'username', value: username);
    await secureStorage.write(key: 'password', value: password);
    print("Data tersimpan di Secure Storage (Mobile)");
  } else {
    // Gunakan enkripsi manual di Railway/backend
    encryptedCredentials = await encryptData(rawData);
    print("Data terenkripsi: $encryptedCredentials");
  }
}

// Fungsi mengambil kredensial
Future<Map<String, String>?> getCredentials() async {
  if (Platform.isAndroid || Platform.isIOS) {
    // Ambil dari Secure Storage di Flutter Mobile
    final username = await secureStorage.read(key: 'username');
    final password = await secureStorage.read(key: 'password');
    if (username != null && password != null) {
      return {'username': username, 'password': password};
    }
  } else {
    // Backend tidak perlu menyimpan state, bisa pakai log server
    print("Data terenkripsi diambil: $encryptedCredentials");
  }
  return null;
}
