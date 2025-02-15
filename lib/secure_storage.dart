import 'package:flutter/foundation.dart'; // Untuk kIsWeb
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SecureStorageService {
  static final SecureStorageService _instance =
      SecureStorageService._internal();

  factory SecureStorageService() {
    return _instance;
  }

  SecureStorageService._internal();

  late final dynamic _storage;

  Future<void> init() async {
    if (kIsWeb) {
      _storage = await SharedPreferences.getInstance();
    } else {
      _storage = const FlutterSecureStorage();
    }
  }

  Future<void> saveCredentials(String username, String password) async {
    if (kIsWeb) {
      await _storage.setString('username', username);
      await _storage.setString('password', password);
    } else {
      await _storage.write(key: 'username', value: username);
      await _storage.write(key: 'password', value: password);
    }
  }

  Future<Map<String, String>?> getCredentials() async {
    if (kIsWeb) {
      final username = _storage.getString('username');
      final password = _storage.getString('password');
      if (username != null && password != null) {
        return {'username': username, 'password': password};
      }
    } else {
      final username = await _storage.read(key: 'username');
      final password = await _storage.read(key: 'password');
      if (username != null && password != null) {
        return {'username': username, 'password': password};
      }
    }
    return null;
  }
}
