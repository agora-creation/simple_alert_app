import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

enum Plan {
  free,
  standard,
  pro,
}

class InAppPurchaseProvider extends ChangeNotifier {
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;

  Plan _plan = Plan.free;
  Plan get plan => _plan;

  String get planName {
    switch (_plan) {
      case Plan.free:
        return 'フリープラン';
      case Plan.standard:
        return 'スタンダードプラン';
      case Plan.pro:
        return 'プロプラン';
    }
  }

  int get planLimit {
    switch (_plan) {
      case Plan.free:
        return 5;
      case Plan.standard:
        return 100;
      case Plan.pro:
        return 500;
    }
  }

  bool get planAdView {
    switch (_plan) {
      case Plan.free:
        return true;
      case Plan.standard:
        return false;
      case Plan.pro:
        return false;
    }
  }

  ProductDetails? _selectedProduct;
  ProductDetails? get selectedProduct => _selectedProduct;
  set selectedProduct(ProductDetails? product) {
    _selectedProduct = product;
    notifyListeners();
  }

  bool isLoading = false;

  //利用可能な商品
  List<ProductDetails> viewProducts = [];

  Completer<bool>? _purchaseCompleter;

  InAppPurchaseProvider() {
    _listenToPurchaseUpdates();
  }

  //商品ID
  Set<String> productIds = {
    'subscription_standard',
    'subscription_pro',
  };

  //利用可能な商品の初期化
  Future initialize() async {
    _plan = Plan.free;
    final bool available = await _inAppPurchase.isAvailable();
    if (!available) {
      print('この端末ではアプリ内課金はご利用いただけません');
    }

    final response = await _inAppPurchase.queryProductDetails(productIds);
    if (response.notFoundIDs.isNotEmpty) {
      print('一部の商品が見つかりませんでした: ${response.notFoundIDs}');
    }

    viewProducts = response.productDetails;
    notifyListeners();

    if (viewProducts.isEmpty) {
      restorePurchases();
    }
  }

  //商品の課金処理
  Future<(bool, String)> purchaseProduct(ProductDetails product) async {
    isLoading = true;
    notifyListeners();
    try {
      final purchaseParam = PurchaseParam(
        productDetails: product,
        applicationUserName: 'com.agoracreation.simple_alert_app',
      );

      if (productIds.contains(product.id)) {
        await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
      }

      _purchaseCompleter = Completer<bool>();

      //プロセス待ち
      final purchaseResult = await _purchaseCompleter!.future.timeout(
        const Duration(seconds: 60),
        onTimeout: () {
          _purchaseCompleter?.complete(false);
          return false;
        },
      );

      if (purchaseResult) {
        return (true, '課金が正常に完了しました');
      } else {
        return (false, '課金が失敗・キャンセルされました');
      }
    } on PlatformException catch (e) {
      if (e.code == 'storekit_duplicate_product_object') {
        return (false, '保留中の処理があります。しばらく待つか、アプリを再起動してください');
      } else {
        return (false, '課金エラーです。もう一度試すか、アプリを再起動してください');
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  //過去の課金を復元する
  Future restorePurchases() async {
    await _inAppPurchase.restorePurchases(
      applicationUserName: 'com.agoracreation.simple_alert_app',
    );
  }

  //課金の最新状況を取得する
  void _listenToPurchaseUpdates() {
    _purchaseSubscription = _inAppPurchase.purchaseStream.listen(
      (List<PurchaseDetails> purchaseDetailsList) {
        for (PurchaseDetails purchaseDetails in purchaseDetailsList) {
          if (purchaseDetails.status == PurchaseStatus.purchased ||
              purchaseDetails.status == PurchaseStatus.restored) {
            _processPurchase(purchaseDetails);
          } else if (purchaseDetails.status == PurchaseStatus.canceled) {
            _handlePurchaseCancellation(purchaseDetails);
          } else if (purchaseDetails.status == PurchaseStatus.error) {
            _handleError(purchaseDetails.error);
          }
        }
      },
      onError: (error) {
        debugPrint('課金Streamエラー: $error');
      },
    );
  }

  //課金の処理と確認
  Future _processPurchase(PurchaseDetails purchaseDetails) async {
    if (purchaseDetails.pendingCompletePurchase) {
      await _inAppPurchase.completePurchase(purchaseDetails);
    }

    try {
      if (purchaseDetails.productID == 'subscription_standard') {
        _plan = Plan.standard;
      } else if (purchaseDetails.productID == 'subscription_pro') {
        _plan = Plan.pro;
      }

      _purchaseCompleter?.complete(true);
    } catch (error) {
      debugPrint('課金処理に失敗しました: $error');
      _purchaseCompleter?.complete(false);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  //課金キャンセル処理
  Future _handlePurchaseCancellation(PurchaseDetails purchaseDetails) async {
    try {
      _plan = Plan.free;

      debugPrint('課金キャンセルは正常に処理されました');
    } catch (error) {
      debugPrint('課金キャンセル処理に失敗しました: $error');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  //課金エラーの処理
  void _handleError(IAPError? error) {
    debugPrint('課金エラー: ${error?.details}');
    _purchaseCompleter?.complete(false);

    isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _purchaseSubscription?.cancel();
    super.dispose();
  }
}
