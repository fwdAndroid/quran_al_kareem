// lib/service/qari_data_store.dart

// Assuming Qari model and ApiCalls exist in your project
import 'package:quran_al_kareem/model/qari_model.dart';
import 'package:quran_al_kareem/api/api_calls.dart';

class QariDataStore {
  // Static field to hold the preloaded data
  static List<Qari> qariList = [];
  static bool isPreloaded = false;
  static String? error;

  // Qaris to be excluded (copied from your AudioQuranScreen)
  static const _excludedQaris = [
    "Al-Hussayni Al-'Azazy (with Children)",
    "Hatem Farid - Taraweeh 1431",
    "Madinah Taraweeh 1435",
    "Mahmoud Khaleel",
    "Mostafa Ismaeel",
    "Mahmoud Khaleel Al-Husary",
    "Sudais and Shuraym",
  ];

  // Static method to fetch and store the data
  static Future<void> preloadData() async {
    if (isPreloaded) return;

    try {
      final api = ApiCalls();
      final qariListRaw = await api.getQariList();

      qariList = qariListRaw
          .where((q) => !(_excludedQaris.contains(q.name?.trim() ?? '')))
          .toList();

      error = null;
      isPreloaded = true;
    } catch (e) {
      error = e.toString();
      isPreloaded = true; // Mark as loaded even on failure
      print("Error preloading Qari list: $e");
    }
  }
}
