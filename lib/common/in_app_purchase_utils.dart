import 'dart:async';

import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

const List<Map<String, String>> kSubscriptions = [
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

class InAppPurchaseUtils extends GetxController {
  InAppPurchaseUtils._();

  static final InAppPurchaseUtils instance = InAppPurchaseUtils._();
  static InAppPurchaseUtils get inAppPurchaseUtilsInstance => instance;
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _purchasesSubscription;

  @override
  void onInit() {
    initialize();
    super.onInit();
  }

  @override
  void onClose() {
    _purchasesSubscription.cancel();
    super.onClose();
  }

  Future initialize() async {
    if (!(await _inAppPurchase.isAvailable())) return;

    _purchasesSubscription = InAppPurchase.instance.purchaseStream.listen(
      (purchaseDetailsList) {
        handlePurchaseUpdates(purchaseDetailsList);
      },
      onDone: () {
        _purchasesSubscription.cancel();
      },
      onError: (error) {},
    );
  }

  void handlePurchaseUpdates(List<PurchaseDetails> purchaseDetailsList) async {
    for (int index = 0; index < purchaseDetailsList.length; index++) {
      var purchaseStatus = purchaseDetailsList[index].status;
      switch (purchaseStatus) {
        case PurchaseStatus.pending:
          continue;
        case PurchaseStatus.error:
          break;
        case PurchaseStatus.canceled:
          break;
        case PurchaseStatus.purchased:
          break;
        case PurchaseStatus.restored:
          break;
      }
    }
  }

  Future buyNonConsumableProduct(String productId) async {
    try {
      Set<String> productIds = {productId};

      final ProductDetailsResponse productDetails =
          await _inAppPurchase.queryProductDetails(productIds);
      final PurchaseParam purchaseParam =
          PurchaseParam(productDetails: productDetails.productDetails.first);
      await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
    } catch (error) {
      print(error.toString());
    }
  }

  void restorePurchases() async {
    try {
      await _inAppPurchase.restorePurchases();
    } catch (error) {
      print(error.toString());
    }
  }
}
