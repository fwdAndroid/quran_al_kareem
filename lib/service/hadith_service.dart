import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/hadith_model.dart';

class HadithService {
  static const String _apiKey =
      r"$2y$10$hI9WsszBgrVpkW2IQnspuExtQqAuDP0guSAwIlKHFUkePZQsEu";
  static const String _baseUrl = "https://hadithapi.com/api/hadiths";

  Future<List<Hadith>> fetchHadiths({
    String book = 'sahih-bukhari',
    int limit = 10,
  }) async {
    final Uri url = Uri.parse(
      "$_baseUrl?book=$book&paginate=$limit&apiKey=$_apiKey",
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonBody = jsonDecode(response.body);
      final data = jsonBody['hadiths']?['data'] ?? [];

      return (data as List).map((item) => Hadith.fromJson(item)).toList();
    } else if (response.statusCode == 401) {
      throw Exception("Unauthorized - Invalid API key");
    } else if (response.statusCode == 403) {
      throw Exception("Forbidden - API key is required or invalid");
    } else {
      throw Exception("Failed to load Hadiths: ${response.statusCode}");
    }
  }
}
