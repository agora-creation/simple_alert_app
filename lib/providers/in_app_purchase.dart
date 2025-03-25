import 'dart:async';

import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class InAppPurchaseProvider extends ChangeNotifier {
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;

  ProductDetails? _selectedProductDetails;
  ProductDetails? get selectedProductDetails => _selectedProductDetails;
  set selectedProductDetails(ProductDetails? productDetails) {
    _selectedProductDetails = productDetails;
    notifyListeners();
  }

  bool isLoading = false;

  //利用可能な商品
  List<ProductDetails> availableProducts = [];

  Completer<bool>? _purchaseCompleter;

  void inAppPurchaseService() {}

  //ローカルストレージのキー
  final String _lastPurchaseDateKey = 'last_purchase_date';
  final String _purchaseDurationKey = 'purchase_duration';

  //サブスクリプションID
  Set<String> productIds = {
    'auto_renew_monthly_plan',
    'auto_renew_annual_plan',
  };

  Future initialize() async {}
}
