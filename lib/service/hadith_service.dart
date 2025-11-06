import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/hadith_model.dart';

class HadithService {
  static const String _apiKey =
      r"$2y$10$hI9WsszBgrVpkW2IQnspuExtQqAuDP0guSAwIlKHFUkePZQsEu";
  static const String _baseUrl = "https://hadithapi.com/api/hadiths";

  /// Fetches *all* hadiths for a given book (loads all pages).
  Future<List<Hadith>> fetchAllHadiths({String book = 'sahih-bukhari'}) async {
    int currentPage = 1;
    bool hasMore = true;
    List<Hadith> allHadiths = [];

    while (hasMore) {
      final Uri url = Uri.parse(
        "$_baseUrl?book=$book&page=$currentPage&apiKey=$_apiKey",
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonBody = jsonDecode(response.body);
        final data = jsonBody['hadiths']?['data'] ?? [];

        if (data.isEmpty) {
          hasMore = false;
        } else {
          allHadiths.addAll(
            (data as List).map((item) => Hadith.fromJson(item)).toList(),
          );

          final meta = jsonBody['hadiths']?['meta'];
          if (meta == null ||
              meta['current_page'] == meta['last_page'] ||
              meta['next_page_url'] == null) {
            hasMore = false;
          } else {
            currentPage++;
          }
        }
      } else if (response.statusCode == 401) {
        throw Exception("Unauthorized - Invalid API key");
      } else if (response.statusCode == 403) {
        throw Exception("Forbidden - API key is required or invalid");
      } else {
        throw Exception("Failed to load Hadiths: ${response.statusCode}");
      }
    }

    return allHadiths;
  }
}
