import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

const List<Map<String, String>> kProductMaps = [
  {
    'id': 'subscription_free',
    'title': 'フリープラン',
    'description': '1ヶ月に10件まで送信可能になります。',
    'price': '¥0/月',
  },
  {
    'id': 'subscription_standard',
    'title': 'スタンダードプラン',
    'description': '1ヶ月に100件まで送信可能になり、バナー広告が非表示になります。',
    'price': '¥900/月',
  },
  {
    'id': 'subscription_pro',
    'title': 'プロプラン',
    'description': '1ヶ月に1000件まで送信可能になり、バナー広告が非表示になります。',
    'price': '¥1,800/月',
  },
];

class InAppPurchaseService {
  InAppPurchaseService._privateConstructor();
  static InAppPurchaseService instance =
      InAppPurchaseService._privateConstructor();
  ValueNotifier<List<ProductDetails>> productsNotifier = ValueNotifier([]);
  ValueNotifier<Set<String>> purchasedProductIds = ValueNotifier({});

  final InAppPurchase _iap = InAppPurchase.instance;
  bool _available = false;

  Future initialize() async {
    _available = await _iap.isAvailable();
    if (_available) {
      getProducts();
      listenToPurchaseUpdates();
    } else {}
  }

  Future getProducts() async {
    const Set<String> kIds = {'subscription_standard', 'subscription_pro'};
    final ProductDetailsResponse response =
        await _iap.queryProductDetails(kIds);
    if (response.notFoundIDs.isNotEmpty) {
      return;
    }
    productsNotifier.value = response.productDetails;
  }

  Future<bool> buySubscription(ProductDetails productDetails) async {
    final PurchaseParam purchaseParam =
        PurchaseParam(productDetails: productDetails);
    try {
      return await _iap.buyNonConsumable(purchaseParam: purchaseParam);
    } on PlatformException catch (e) {
      print(e.toString());
      return false;
    }
  }

  void listenToPurchaseUpdates() {
    _iap.purchaseStream.listen((purchases) {
      for (var purchase in purchases) {
        if (purchase.status == PurchaseStatus.purchased) {
          _iap.completePurchase(purchase);
          purchasedProductIds.value = {
            ...purchasedProductIds.value,
            purchase.productID
          };
        } else if (purchase.status == PurchaseStatus.error) {
        } else if (purchase.status == PurchaseStatus.canceled) {
          _iap.completePurchase(purchase);
        } else if (purchase.status == PurchaseStatus.pending) {
        } else if (purchase.status == PurchaseStatus.restored) {}
      }
    });
  }

  Future restorePurchases() async {
    await _iap.restorePurchases();
  }
}
