import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiServiceTest {
  final String baseUrl;

  ApiServiceTest(this.baseUrl);

  // Fungsi untuk menguji pengambilan data dari endpoint
  Future<void> testFetchData(String endpoint, {String? token}) async {
    print('Testing fetch data from endpoint: $endpoint');
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/$endpoint'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        print('Fetch data successful from $endpoint:');
        print(jsonDecode(response.body));
      } else {
        print(
            'Failed to fetch data from $endpoint (status code: ${response.statusCode})');
      }
    } catch (e) {
      print('Error fetching data from $endpoint: $e');
    }
  }

  // Fungsi untuk menguji pengiriman data ke endpoint
  Future<void> testPostRiwayatDiagnosa(
      String endpoint, Map<String, dynamic> data,
      {String? token}) async {
    print('Testing post data to endpoint: $endpoint');
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/$endpoint'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        print('Post data successful to $endpoint');
      } else {
        print(
            'Failed to post data to $endpoint (status code: ${response.statusCode})');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error posting data to $endpoint: $e');
    }
  }
}
