// import 'dart:async';
//
// import 'package:get/get.dart';
// import 'package:in_app_purchase/in_app_purchase.dart';
//
// class InAppPurchaseUtils extends GetxController {
//   //Private constructor
//   InAppPurchaseUtils._();
//
//   //Singleton instance
//   static final InAppPurchaseUtils instance = InAppPurchaseUtils._();
//
//   //Getter to access the instance
//   static InAppPurchaseUtils get inAppPurchaseUtilsInstance => instance;
//
//   //Create a private variable
//   final InAppPurchase _iap = InAppPurchase.instance;
//
//   late StreamSubscription<List<PurchaseDetails>> _purchasesSubscription;
//
//   @override
//   void onInit() {
//     initialize();
//     super.onInit();
//   }
//
//   @override
//   void onClose() {
//     _purchasesSubscription.cancel();
//     super.onClose();
//   }
//
//   Future initialize() async {
//     if (!(await _iap.isAvailable())) return;
//
//     //catch all purchase updates
//     _purchasesSubscription = InAppPurchase.instance.purchaseStream.listen(
//       (List<PurchaseDetails> purchaseDetailsList) {
//         handlePurchaseUpdates(purchaseDetailsList);
//       },
//       onDone: () {
//         _purchasesSubscription.cancel();
//       },
//       onError: (e) {},
//     );
//   }
//
//   void handlePurchaseUpdates(List<PurchaseDetails> purchaseDetailsList) async {}
//
//   void restorePurchases() async {
//     try {
//       await _iap.restorePurchases();
//     } catch (e) {
//       //You can handle the error here
//     }
//   }
// }
