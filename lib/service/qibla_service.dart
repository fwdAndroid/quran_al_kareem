import 'dart:convert';

import 'package:http/http.dart' as http;

class QiblaApiService {
  static const String _apiUrl = 'https://api.aladhan.com/v1/qibla/';

  static Future<Map<String, dynamic>> getQiblaDirection(
    double latitude,
    double longitude,
  ) async {
    final response = await http.get(Uri.parse('$_apiUrl$latitude/$longitude'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load Qibla direction');
    }
  }
}
