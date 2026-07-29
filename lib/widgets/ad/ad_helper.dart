import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:question_app/data/data.dart';

class AdHelper {
  static const String testBannerAdUnitId =
      'ca-app-pub-2715802718577529/6531618861';
  static const String testInterstitialAdUnitId =
      'ca-app-pub-2715802718577529/6168536647';
  static const String testRewardedAdUnitId =
      'ca-app-pub-2715802718577529/7078413774';
  static InterstitialAd? _interstitialAd;
  static bool _isLoading = false;
  static StreamSubscription<List<ConnectivityResult>>? _networkSubscription;

  // Get the bannerAd Id
  static String get bannerAdUnitId {
    if (kDebugMode) {
      return testBannerAdUnitId;
    } else if (Platform.isAndroid) {
      return testBannerAdUnitId;
    } else if (Platform.isIOS) {
      return testBannerAdUnitId;
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  // Get the InterstitialAdUnitId
  static String get interstitialAdUnitId {
    if (kDebugMode) {
      return testInterstitialAdUnitId;
    } else if (Platform.isAndroid) {
      return testInterstitialAdUnitId;
    } else if (Platform.isIOS) {
      return testInterstitialAdUnitId;
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  // Load interstitial ad
  static void loadInterstitial() {
    if (_isLoading || _interstitialAd != null || showAds == false) {
      return;
    }

    _isLoading = true;

    InterstitialAd.load(
      adUnitId: AdHelper.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isLoading = false;

          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _interstitialAd = null;
              loadInterstitial(); // preload next
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _interstitialAd = null;
              loadInterstitial();
            },
          );
        },
        onAdFailedToLoad: (error) {
          _isLoading = false;
          if (kDebugMode) {
            print('Interstitial failed: ${error.message}');
          }
        },
      ),
    );
  }

  // Show interstitial ad
  static void showInterstitialIfReady({VoidCallback? onFinished}) {
    if (_interstitialAd == null) {
      onFinished?.call();
      if (kDebugMode) {
        print('Interstitial not ready yet.');
      }
      return;
    }

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) async {
        ad.dispose();
        _interstitialAd = null;
        loadInterstitial();
        onFinished?.call();
      },
      onAdFailedToShowFullScreenContent: (ad, error) async {
        ad.dispose();
        _interstitialAd = null;
        loadInterstitial();
        onFinished?.call();
      },
    );

    _interstitialAd!.show();
  }

  // Check connection of wifi
  static void initNetworkListener() {
    if (_networkSubscription != null) return; // prevent multiple listeners

    List<ConnectivityResult> connected = [
      ConnectivityResult.mobile,
      ConnectivityResult.wifi,
      ConnectivityResult.ethernet,
    ];

    _networkSubscription = Connectivity().onConnectivityChanged.listen((
      results,
    ) {
      bool isOnline = results.any((result) => connected.contains(result));

      if (isOnline && _interstitialAd == null) {
        loadInterstitial();
      }
    });
  }
}
