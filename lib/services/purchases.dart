import 'dart:io';

import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class PurchasesService {
  Future init() async {
    // await Purchases.setLogLevel(LogLevel.debug);
    PurchasesConfiguration? config;

    if (Platform.isAndroid) {
      config = PurchasesConfiguration('goog_uzjJwRwBhkQBrvrVaNMMLRIaGUJ');
    } else if (Platform.isIOS) {
      config = PurchasesConfiguration('appl_BaHDapWOCjBvDTvFDUVNApJETsB');
    }
    if (config != null) {
      await Purchases.configure(config);
    }
  }

  Future<PaywallResult> showPaywall() async {
    return await RevenueCatUI.presentPaywallIfNeeded('subscription');
  }

  String getName(String id) {
    switch (id) {
      case 'subscription_standard':
        return 'スタンダードプラン';
      case 'subscription_pro':
        return 'プロプラン';
      default:
        return '';
    }
  }

  int getMonthSendLimit(String id) {
    switch (id) {
      case 'subscription_standard':
        return 100;
      case 'subscription_pro':
        return 1000;
      default:
        return 0;
    }
  }

  Future openSubscriptionManagement() async {
    String url = '';
    if (Platform.isIOS) {
      url = 'https://apps.apple.com/account/subscriptions';
    } else if (Platform.isAndroid) {
      url = 'https://play.google.com/store/account/subscriptions';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }
}
