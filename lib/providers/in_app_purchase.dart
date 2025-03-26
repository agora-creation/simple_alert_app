import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  void inAppPurchaseService() {
    _listenToPurchaseUpdates();
  }

  //サブスクリプションID
  Set<String> productIds = {
    'subscription_standard',
    'subscription_pro',
  };

  //利用可能な商品の初期化
  Future initialize() async {
    final bool available = await _inAppPurchase.isAvailable();
    if (!available) {
      print('この端末ではアプリ内課金ができません');
    }

    final ProductDetailsResponse response =
        await _inAppPurchase.queryProductDetails(productIds);
    if (response.notFoundIDs.isNotEmpty) {
      throw Exception('一部の商品が見つかりませんでした: ${response.notFoundIDs}');
    }

    availableProducts = response.productDetails;
    notifyListeners();

    if (availableProducts.isEmpty) {
      restorePurchases();
    }
  }

  //商品の課金処理
  Future<(bool, String)> purchaseProduct(ProductDetails product) async {
    isLoading = true;
    notifyListeners();
    try {
      final PurchaseParam purchaseParam = PurchaseParam(
        productDetails: product,
        applicationUserName: 'ap.screenshot.pro',
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
      applicationUserName: 'ap.screenshot.pro',
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
        //Firestore更新
      } else if (purchaseDetails.productID == 'subscription_pro') {
        //Firestore更新
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
      //Firestore更新

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
