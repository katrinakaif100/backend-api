import 'dart:convert';
import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';
import 'package:crypto/crypto.dart';
import 'package:collection/collection.dart';

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
const String riwayatdiagnosaFile = 'riwayat_diagnosa.json';
const String perawatanFile = 'perawatan.json';
const String informasicampakFile = 'informasi_campak.json';
const String gejalaFile = 'gejala.json';
const String makananFile = 'makanan.json';
const String faqFile = 'faq.json';
const String artikelFile = 'artikel.json';

// Fungsi handler utama
Future<Response> _handler(Request req) async {
  final router = Router();

  // Endpoint login
  router.post('/login', _handleLogin);

  // Endpoint menerima dan mengelola data JSON
  _registerAdminEndpoints(router);

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
    final jsonData = await file.readAsString();
    return Response.ok(jsonData, headers: {'Content-Type': 'application/json'});
  } else {
    return Response.notFound(jsonEncode({'error': 'Data not found'}));
  }
}

// Fungsi generik untuk POST data
Future<Response> _postData(String filePath, Request request) async {
  final body = await request.readAsString();
  try {
    final jsonData = jsonDecode(body);
    if (jsonData is! Map<String, dynamic> && jsonData is! List) {
      throw FormatException('Invalid JSON format');
    }
    final file = File(filePath);
    await file.writeAsString(jsonEncode(jsonData), flush: true);
    return Response.ok(jsonEncode({'message': 'Data saved successfully'}));
  } catch (e) {
    return Response.badRequest(
        body: jsonEncode({'error': 'Invalid JSON', 'details': e.toString()}));
  }
}

// Fungsi untuk mendaftarkan endpoint admin
void _registerAdminEndpoints(Router router) {
  router.get('/admin/riwayat_diagnosa',
      (Request req) => _getData(riwayatdiagnosaFile));
  router.post('/admin/riwayat_diagnosa',
      (Request req) => _postData(riwayatdiagnosaFile, req));

  router.get('/admin/perawatan', (Request req) => _getData(perawatanFile));
  router.post(
      '/admin/perawatan', (Request req) => _postData(perawatanFile, req));

  router.get('/admin/informasi_campak',
      (Request req) => _getData(informasicampakFile));
  router.post('/admin/informasi_campak',
      (Request req) => _postData(informasicampakFile, req));

  router.get('/admin/gejala', (Request req) => _getData(gejalaFile));
  router.post('/admin/gejala', (Request req) => _postData(gejalaFile, req));

  router.get('/admin/makanan', (Request req) => _getData(makananFile));
  router.post('/admin/makanan', (Request req) => _postData(makananFile, req));

  router.get('/admin/faq', (Request req) => _getData(faqFile));
  router.post('/admin/faq', (Request req) => _postData(faqFile, req));

  router.get('/admin/artikel', (Request req) => _getData(artikelFile));
  router.post('/admin/artikel', (Request req) => _postData(artikelFile, req));
}

// Fungsi utama untuk menjalankan server
Future<void> serve(int port) async {
  final handler =
      const Pipeline().addMiddleware(logRequests()).addHandler(_handler);
  final server = await io.serve(handler, InternetAddress.anyIPv4, port);
  print('Server listening on port ${server.port}');
}
