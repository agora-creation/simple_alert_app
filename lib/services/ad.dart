import 'dart:io';

import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  static String get appId {
    if (Platform.isAndroid) {
      return 'AndroidのアプリID';
    } else if (Platform.isIOS) {
      return 'iOSのアプリID';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
//      return 'ca-app-pub-3940256099942544/6300978111'; // テストID
      return 'ca-app-pub-9791675225952080/1935914100';
    } else if (Platform.isIOS) {
//      return 'ca-app-pub-3940256099942544/6300978111'; // テストID
      return 'ca-app-pub-9791675225952080/8033578271';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  static BannerAd createBannerAd() {
    return BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.fullBanner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) => print('バナー広告がロードされました'),
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          ad.dispose();
          print('バナー広告の読み込みが次の理由で失敗しました: $error');
        },
        onAdOpened: (Ad ad) => print('バナー広告が開かれました'),
        onAdClosed: (Ad ad) => print('バナー広告が閉じられました'),
        onAdImpression: (Ad ad) => print('次のバナー広告が表示されました: $ad'),
      ),
    );
  }
}
