import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:provider/provider.dart';
import 'package:simple_alert_app/common/functions.dart';
import 'package:simple_alert_app/common/style.dart';
import 'package:simple_alert_app/widgets/custom_button.dart';
import 'package:simple_alert_app/widgets/link_text.dart';
import 'package:simple_alert_app/widgets/product_map_list.dart';
import 'package:url_launcher/url_launcher.dart';

Set<String> kProductIds = {
  'subscription_standard',
  'subscription_pro',
};
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

Future<String> getPlanName() async {
  String purchasePlan =
      await getPrefsString('purchasePlan') ?? 'subscription_free';
  switch (purchasePlan) {
    case 'subscription_free':
      return 'フリープラン';
    case 'subscription_standard':
      return 'スタンダードプラン';
    case 'subscription_pro':
      return 'プロプラン';
    default:
      return 'フリープラン';
  }
}

Future<int> getMonthSendLimit() async {
  String purchasePlan =
      await getPrefsString('purchasePlan') ?? 'subscription_free';
  switch (purchasePlan) {
    case 'subscription_free':
      return 10;
    case 'subscription_standard':
      return 100;
    case 'subscription_pro':
      return 1000;
    default:
      return 10;
  }
}

class InAppPurchaseProvider extends ChangeNotifier {
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;

  String _selectedProductId = kProductMaps[0]['id'].toString();
  String get selectedProductId => _selectedProductId;
  set selectedProductId(String productId) {
    _selectedProductId = productId;
    notifyListeners();
  }

  bool isLoading = false;

  //利用可能な商品
  List<ProductDetails> availableProducts = [];

  Completer<bool>? _purchaseCompleter;

  InAppPurchaseProvider() {
    _listenToPurchaseUpdates();
  }

  //利用可能な商品を初期化して再取得する
  Future initialize() async {
    final bool available = await _inAppPurchase.isAvailable();
    if (!available) {
      throw Exception('この端末ではアプリ内課金はご利用いただけません');
    }

    ProductDetailsResponse response = await _inAppPurchase.queryProductDetails(
      kProductIds,
    );
    if (response.notFoundIDs.isNotEmpty) {
      throw Exception('一部の商品が見つかりませんでした: ${response.notFoundIDs}');
    }

    availableProducts = response.productDetails;
    notifyListeners();

    if (availableProducts.isEmpty) {
      restorePurchases();
    }
  }

  //商品の購入処理
  Future<(bool, String)> purchaseProduct(ProductDetails product) async {
    isLoading = true;
    notifyListeners();
    try {
      final PurchaseParam purchaseParam = PurchaseParam(
        productDetails: product,
        applicationUserName: Platform.isAndroid
            ? 'com.agoracreation.simple_alert_app'
            : 'com.agoracreation.simpleAlertApp',
      );

      if (kProductIds.contains(product.id)) {
        await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
      }

      _purchaseCompleter = Completer<bool>();

      //購入プロセスが完了するかタイムアウトするまで待ちます
      final purchaseResult = await _purchaseCompleter!.future.timeout(
        const Duration(seconds: 60),
        onTimeout: () {
          _purchaseCompleter?.complete(false);
          return false;
        },
      );

      if (purchaseResult) {
        return (true, '購入は正常に完了しました');
      } else {
        return (false, '購入に失敗しました');
      }
    } on PlatformException catch (e) {
      if (e.code == 'storekit_duplicate_product_object') {
        //保留中の取引についてユーザーに通知する
        return (false, '保留中の処理があります。お待ちいただくか、アプリを再起動してください。');
      } else {
        //その他のエラー処理
        return (false, '購入エラーです。再度お試しいただくか、アプリを再起動してください。');
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  //過去の購入を復元する
  Future restorePurchases() async {
    await _inAppPurchase.restorePurchases(
      applicationUserName: Platform.isAndroid
          ? 'com.agoracreation.simple_alert_app'
          : 'com.agoracreation.simpleAlertApp',
    );
  }

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
        debugPrint('Purchase stream error: $error');
      },
    );
  }

  //購入の処理と確認
  Future _processPurchase(PurchaseDetails purchaseDetails) async {
    if (purchaseDetails.pendingCompletePurchase) {
      await _inAppPurchase.completePurchase(purchaseDetails);
    }

    try {
      //端末内DB保存
      await setPrefsString('purchasePlan', selectedProductId);
      await setPrefsInt(
          'purchasePlanAt', DateTime.now().millisecondsSinceEpoch);

      _purchaseCompleter?.complete(true);
    } catch (error) {
      debugPrint('購入処理に失敗しました: $error');
      _purchaseCompleter?.complete(false);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  //購入キャンセルの処理
  Future _handlePurchaseCancellation(PurchaseDetails purchaseDetails) async {
    try {
      debugPrint('購入キャンセルは正常に処理されました');
    } catch (error) {
      debugPrint('購入キャンセルに失敗しました: $error');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  //購入エラーの処理
  void _handleError(IAPError? error) {
    debugPrint('購入エラー: ${error?.details}');
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

void showInAppPurchaseDialog(
  BuildContext context, {
  required Function(String) result,
}) async {
  String? purchasePlan = await getPrefsString('purchasePlan');
  if (purchasePlan != null) {
    context.read<InAppPurchaseProvider>().selectedProductId = purchasePlan;
  }
  showModalBottomSheet<bool?>(
    backgroundColor: kWhiteColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(16),
        topRight: Radius.circular(16),
      ),
    ),
    showDragHandle: true,
    context: context,
    builder: (BuildContext context) {
      return Consumer<InAppPurchaseProvider>(
        builder: (context, inAppPurchaseProvider, _) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'ご利用プランを選ぶ',
                    style: TextStyle(
                      color: kBlackColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'SourceHanSansJP-Bold',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '選択したプランにより、送信制限が解放され、広告を非表示にすることができます。',
                    style: TextStyle(
                      color: kBlackColor.withOpacity(0.5),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Column(
                    children: kProductMaps.map((productMap) {
                      return ProductMapList(
                        productMap: productMap,
                        selectedId: inAppPurchaseProvider.selectedProductId,
                        onTap: () {
                          inAppPurchaseProvider.selectedProductId =
                              productMap['id'].toString();
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  LinkText(
                    label: '利用規約',
                    onTap: () async {
                      if (!await launchUrl(Uri.parse(
                        'https://docs.google.com/document/d/18yzTySjHTdCE_VHS6NjAeP8OfTpfqyh5VZjaqBgdP78/edit?usp=sharing',
                      ))) {
                        throw Exception('Could not launch');
                      }
                    },
                  ),
                  const SizedBox(height: 8),
                  CustomButton(
                    type: ButtonSizeType.lg,
                    label: '選択したプランで始める',
                    labelColor: kWhiteColor,
                    backgroundColor: kBlueColor,
                    onPressed: () => Navigator.of(context).pop(true),
                  ),
                  const SizedBox(height: 24),
                  LinkText(
                    label: '過去の購入を復元する',
                    onTap: () {
                      inAppPurchaseProvider.restorePurchases();
                      Navigator.of(context).pop();
                    },
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          );
        },
      );
    },
  ).then((value) async {
    if (value != true || !context.mounted) return;
    result(
      context.read<InAppPurchaseProvider>().selectedProductId,
    );
  });
}
