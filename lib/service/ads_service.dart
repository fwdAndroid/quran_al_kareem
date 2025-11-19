import 'dart:ui';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AppOpenAdManager {
  String adUnitId = "ca-app-pub-3940256099942544/3419835294";

  AppOpenAd? _appOpenAd;
  bool _isShowingAd = false;
  DateTime? _loadTime;
  final Duration maxCacheDuration = Duration(hours: 4);

  // Expose _appOpenAd via getter
  AppOpenAd? get appOpenAd => _appOpenAd;

  bool get isAdAvailable => _appOpenAd != null;

  /// Load an App Open Ad
  void loadAd() {
    AppOpenAd.load(
      adUnitId: adUnitId,
      request: AdRequest(),
      // orientation: AppOpenAd.orientationPortrait,
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _appOpenAd = ad;
          _loadTime = DateTime.now();
          print('AppOpenAd loaded');
        },
        onAdFailedToLoad: (error) {
          print('AppOpenAd failed to load: $error');
        },
      ),
    );
  }

  /// Show the ad if available
  void showAdIfAvailable({VoidCallback? onAdClosed}) {
    if (!isAdAvailable) {
      print('Ad not ready. Loading...');
      loadAd();
      onAdClosed?.call();
      return;
    }

    if (_isShowingAd) return;

    // Check ad expiration
    if (_loadTime != null &&
        DateTime.now().subtract(maxCacheDuration).isAfter(_loadTime!)) {
      print('Ad expired. Loading new ad.');
      _appOpenAd!.dispose();
      _appOpenAd = null;
      loadAd();
      onAdClosed?.call();
      return;
    }

    _appOpenAd!.fullScreenContentCallback =
        FullScreenContentCallback<AppOpenAd>(
          onAdShowedFullScreenContent: (ad) {
            _isShowingAd = true;
            print('App Open Ad showed');
          },
          onAdFailedToShowFullScreenContent: (ad, error) {
            print('Ad failed to show: $error');
            _isShowingAd = false;
            ad.dispose();
            _appOpenAd = null;
            onAdClosed?.call();
          },
          onAdDismissedFullScreenContent: (ad) {
            print('App Open Ad dismissed');
            _isShowingAd = false;
            ad.dispose();
            _appOpenAd = null;
            loadAd(); // preload next ad
            onAdClosed?.call();
          },
        );

    _appOpenAd!.show();
  }
}
