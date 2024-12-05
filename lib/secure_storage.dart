import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final storage = FlutterSecureStorage();

Future<void> saveCredentials(String username, String password) async {
  await storage.write(key: 'username', value: username);
  await storage.write(key: 'password', value: password);
}

Future<Map<String, String>?> getCredentials() async {
  final username = await storage.read(key: 'username');
  final password = await storage.read(key: 'password');
  if (username != null && password != null) {
    return {'username': username, 'password': password};
  }
  return null;
}
