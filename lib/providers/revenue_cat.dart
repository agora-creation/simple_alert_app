import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class RevenueCatProvider extends ChangeNotifier {
  RevenueCatProvider() {
    init();
  }

  Future init() async {
    Purchases.addCustomerInfoUpdateListener((info) async {
      updatePurchaseStatus();
    });
  }

  Future updatePurchaseStatus() async {
    final purchaserInfo = await Purchases.getCustomerInfo();
    final entitlements = purchaserInfo.entitlements.active.values.toList();
  }
}
