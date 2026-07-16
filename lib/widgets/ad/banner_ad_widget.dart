import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:question_app/data/data.dart';
import 'ad_helper.dart';

class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({super.key});

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> with RouteAware {
  BannerAd? _bannerAd;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    if (!showAds) return;

    _bannerAd = BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (mounted) {
            setState(() {});
          }
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          if (kDebugMode) {
            print('Banner failed: ${error.message}');
          }
        },
      ),
    )..load();
  }

  @override
  void didPushNext() {
    // The route was covered by another route, so we can dispose the ad
    _bannerAd?.dispose();
    _bannerAd = null;
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void didPopNext() {
    // The route that covered this route was popped, so we're visible again
    _loadAd();
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_bannerAd == null || showAds == false) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      width: _bannerAd!.size.width.toDouble(),
      height: _bannerAd!.size.height.toDouble(),
      child: AdWidget(ad: _bannerAd!),
    );
  }
}
