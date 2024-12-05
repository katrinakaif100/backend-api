import 'dart:convert';
import 'dart:io';
import 'package:test/test.dart';
import 'package:http/http.dart' as http;

void main() {
  const baseUrl = 'http://192.168.0.140:8080';
  const adminToken =
      'Bearer kuncirahasiaku'; // Gunakan token JWT yang sesuai jika diperlukan

  group('API Service Tests', () {
    late Process serverProcess;

    setUpAll(() async {
      // Jalankan server sebelum pengujian
      serverProcess = await Process.start(
        'dart',
        ['run', 'server.dart'],
        runInShell: true,
      );

      // Berikan waktu untuk server siap
      await Future.delayed(const Duration(seconds: 2));
    });

    tearDownAll(() async {
      // Matikan server setelah pengujian
      serverProcess.kill();
    });

    Future<void> testEndpoint(
        String endpoint, Map<String, dynamic> data) async {
      // POST data
      var response = await http.post(
        Uri.parse('$baseUrl/admin/$endpoint'),
        headers: {
          'Authorization': adminToken,
          'Content-Type': 'application/json'
        },
        body: jsonEncode(data),
      );
      expect(response.statusCode, equals(200));

      // GET data
      response = await http.get(
        Uri.parse('$baseUrl/admin/$endpoint'),
        headers: {'Authorization': adminToken},
      );
      expect(response.statusCode, equals(200));
      final responseBody = jsonDecode(response.body);
      expect(responseBody, equals(data));
    }

    test('Login endpoint with valid credentials', () async {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': 'admin', 'password': 'admin123'}),
      );

      expect(response.statusCode, equals(200));
      final body = jsonDecode(response.body);
      expect(body, contains('token'));
    });

    test('Login endpoint with invalid credentials', () async {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': 'admin', 'password': 'wrongpass'}),
      );

      expect(response.statusCode, equals(403));
    });

    test('Riwayat Diagnosa endpoint', () async {
      const data = {
        'diagnosa': 'Campak',
        'tanggal': '2024-12-01',
        'gejala': ['Demam', 'Batuk']
      };
      await testEndpoint('riwayat_diagnosa', data);
    });

    test('Perawatan endpoint', () async {
      const data = {
        'judul': 'Perawatan Campak',
        'deskripsi': 'Istirahat cukup dan konsumsi cairan.'
      };
      await testEndpoint('perawatan', data);
    });

    test('Informasi Campak endpoint', () async {
      const data = {
        'judul': 'Campak',
        'konten': 'Campak adalah penyakit menular yang disebabkan oleh virus.'
      };
      await testEndpoint('informasi_campak', data);
    });

    test('Gejala endpoint', () async {
      const data = {
        'gejala': ['Demam tinggi', 'Ruam merah', 'Batuk'],
      };
      await testEndpoint('gejala', data);
    });

    test('Makanan endpoint', () async {
      const data = {
        'makanan': ['Sup ayam', 'Air kelapa', 'Buah-buahan segar'],
      };
      await testEndpoint('makanan', data);
    });

    test('FAQ endpoint', () async {
      const data = {
        'pertanyaan': 'Apakah campak menular?',
        'jawaban': 'Ya, campak sangat menular melalui udara.',
      };
      await testEndpoint('faq', data);
    });

    test('Artikel endpoint', () async {
      const data = {
        'judul': 'Mencegah Campak',
        'konten': 'Vaksinasi adalah cara paling efektif untuk mencegah campak.',
      };
      await testEndpoint('artikel', data);
    });
  });
}
