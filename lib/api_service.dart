import 'dart:convert';
import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';
import 'package:crypto/crypto.dart';
import 'package:collection/collection.dart';

// Middleware untuk menangani CORS di semua request
Middleware corsMiddleware = (Handler innerHandler) {
  return (Request request) async {
    if (request.method == 'OPTIONS') {
      return Response.ok('', headers: _corsHeaders);
    }
    Response response = await innerHandler(request);
    return response.change(headers: _corsHeaders);
  };
};

// Header CORS yang akan diterapkan ke semua response
const Map<String, String> _corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type, Authorization',
};

// Fungsi untuk membuat JWT
String generateJwt(String username, String secretKey) {
  final payload = jsonEncode({'username': username});
  final key = utf8.encode(secretKey);
  final hmacSha256 = Hmac(sha256, key);
  final hmacDigest = hmacSha256.convert(utf8.encode(payload));
  return '$payload.${base64Encode(hmacDigest.bytes)}';
}

// Fungsi untuk memverifikasi JWT
bool verifyJwt(String token, String secretKey) {
  final parts = token.split('.');
  if (parts.length != 2) return false;
  final payload = parts[0];
  final signature = base64Decode(parts[1]);
  final key = utf8.encode(secretKey);
  final hmacSha256 = Hmac(sha256, key);
  final hmacDigest = hmacSha256.convert(utf8.encode(payload));
  return const ListEquality().equals(hmacDigest.bytes, signature);
}

// Lokasi file JSON di server
const String riwayatdiagnosaFile = 'android/storage/riwayat_diagnosa.json';
const String perawatanFile = 'android/storage/perawatan.json';
const String informasicampakFile = 'android/storage/informasi_campak.json';
const String gejalaFile = 'android/storage/gejala.json';
const String makananFile = 'android/storage/makanan.json';
const String faqFile = 'android/storage/faq.json';
const String artikelFile = 'android/storage/artikel.json';

// Fungsi handler utama
Future<Response> _handler(Request req) async {
  final router = Router();

  // Endpoint login untuk otentikasi (admin)
  router.post('/login', _handleLogin);

  // Endpoint untuk Admin
  _registerAdminEndpoints(router); // Pendaftaran endpoint admin

  // Endpoint untuk Pengguna
  _registerUserEndpoints(router); // Pendaftaran endpoint pengguna

  return router(req);
}

// Fungsi login
Future<Response> _handleLogin(Request request) async {
  final body = await request.readAsString();
  final data = jsonDecode(body);
  final username = data['username'];
  final password = data['password'];

  // Login logic
  if (username == 'admin' && password == 'admin123') {
    final token = generateJwt(username, 'kuncirahasiaku');
    return Response.ok(jsonEncode({'token': token}));
  } else {
    return Response.forbidden('Invalid credentials');
  }
}

// Fungsi generik untuk GET data
Future<Response> _getData(String filePath) async {
  final file = File(filePath);
  if (await file.exists()) {
    try {
      final jsonData = await file.readAsString();
      final parsedData = jsonDecode(jsonData);
      return Response.ok(
        jsonEncode(parsedData),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode(
            {'error': 'Failed to parse JSON', 'details': e.toString()}),
      );
    }
  } else {
    return Response.notFound(
      jsonEncode({'error': 'Data not found'}),
    );
  }
}

// Fungsi generik untuk POST data
Future<Response> _postData(String filePath, Request request) async {
  try {
    final body = await request.readAsString();
    final jsonData = jsonDecode(body); // Mendukung bentuk list atau map

    // Simpan ke file tanpa memodifikasi format
    final file = File(filePath);
    await file.writeAsString(
      jsonEncode(jsonData),
      flush: true,
    );

    return Response.ok(
      jsonEncode({'message': 'Data saved successfully'}),
    );
  } catch (e) {
    return Response.badRequest(
      body: jsonEncode({'error': 'Invalid JSON', 'details': e.toString()}),
    );
  }
}

// Fungsi untuk mendaftarkan endpoint admin
void _registerAdminEndpoints(Router router) {
  router.get('/admin/riwayat_diagnosa',
      (Request req) => _getData(riwayatdiagnosaFile));
  router.post('/admin/riwayat_diagnosa',
      (Request req) => _postData(riwayatdiagnosaFile, req));
}

// Fungsi untuk mendaftarkan endpoint pengguna
void _registerUserEndpoints(Router router) {
  router.get('/api/perawatan', (Request req) => _getData(perawatanFile));
  router.get(
      '/api/informasi_campak', (Request req) => _getData(informasicampakFile));
  router.get('/api/gejala', (Request req) => _getData(gejalaFile));
  router.get('/api/makanan', (Request req) => _getData(makananFile));
  router.get('/api/faq', (Request req) => _getData(faqFile));
  router.get('/api/artikel', (Request req) => _getData(artikelFile));
  router.post('/api/riwayat_diagnosa',
      (Request req) => _postData(riwayatdiagnosaFile, req));
}

// Fungsi utama untuk menjalankan server
Future<void> serve(int port) async {
  final handler = Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(corsMiddleware) // ✅ Tambahkan middleware CORS
      .addHandler(_handler);

  final server = await io.serve(handler, InternetAddress.anyIPv4, port);
  print('Server listening on port ${server.port}');
}
