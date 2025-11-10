import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsHelper {
  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  static Future<void> logScreenView(String screenName) async {
    await analytics.logEvent(
      name: 'screen_view',
      parameters: {'screen_name': screenName, 'screen_class': screenName},
    );
    // Optional debug
    // print("Screen logged: $screenName");
  }

  static Future<void> logEvent(
    String name, {
    Map<String, dynamic>? parameters,
  }) async {
    await analytics.logEvent(
      name: name,
      parameters: parameters?.cast<String, Object>(),
    );
  }
}
