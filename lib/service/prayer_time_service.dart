import 'dart:convert';
import 'package:http/http.dart' as http;

class PrayerTimeService {
  static Future<Map<String, dynamic>> fetchPrayerTimes({
    required double latitude,
    required double longitude,
  }) async {
    final now = DateTime.now();
    final timestamp = now.millisecondsSinceEpoch ~/ 1000;

    final url = Uri.parse(
      'https://api.aladhan.com/v1/timings/$timestamp?latitude=$latitude&longitude=$longitude&method=2',
    );

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return {'timings': data['data']['timings'], 'date': data['data']['date']};
    } else {
      throw Exception('Failed to fetch prayer times');
    }
  }
}
