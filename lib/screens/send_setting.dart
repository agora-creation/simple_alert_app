import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:simple_alert_app/common/style.dart';
import 'package:simple_alert_app/models/user.dart';
import 'package:simple_alert_app/providers/in_app_purchase.dart';
import 'package:simple_alert_app/providers/user.dart';
import 'package:simple_alert_app/screens/home.dart';
import 'package:simple_alert_app/screens/send_setting_name.dart';
import 'package:simple_alert_app/screens/send_setting_qr.dart';
import 'package:simple_alert_app/screens/send_setting_users.dart';
import 'package:simple_alert_app/services/user_send.dart';
import 'package:simple_alert_app/widgets/custom_alert_dialog.dart';
import 'package:simple_alert_app/widgets/custom_button.dart';
import 'package:simple_alert_app/widgets/link_text.dart';
import 'package:simple_alert_app/widgets/product_list.dart';
import 'package:simple_alert_app/widgets/setting_list.dart';
import 'package:url_launcher/url_launcher.dart';

class SendSettingScreen extends StatefulWidget {
  final UserProvider userProvider;

  const SendSettingScreen({
    required this.userProvider,
    super.key,
  });

  @override
  State<SendSettingScreen> createState() => _SendSettingScreenState();
}

class _SendSettingScreenState extends State<SendSettingScreen> {
  int monthSendCount = 0;

  void _init() async {
    if (widget.userProvider.user != null) {
      monthSendCount = await UserSendService().selectMonthSendCount(
        userId: widget.userProvider.user!.id,
      );
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  Widget build(BuildContext context) {
    final inAppPurchaseProvider = context.read<InAppPurchaseProvider>();
    UserModel? user = widget.userProvider.user;
    return Scaffold(
      backgroundColor: kWhiteColor,
      appBar: AppBar(
        backgroundColor: kWhiteColor,
        automaticallyImplyLeading: false,
        title: const Text(
          '送信設定',
          style: TextStyle(color: kBlackColor),
        ),
        actions: [
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.xmark),
            onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            SettingList(
              label: 'ご利用中のプラン',
              subtitle: Text(
                context.read<InAppPurchaseProvider>().planName,
                style: TextStyle(
                  color: kBlackColor,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'SourceHanSansJP-Bold',
                ),
              ),
              trailing: const FaIcon(
                FontAwesomeIcons.rotate,
                size: 16,
              ),
              onTap: () {
                if (inAppPurchaseProvider.plan == Plan.free) {
                  showSubscriptionDialog(
                    context,
                    result: (product) async {
                      if (product == null) return;
                      final result =
                          await inAppPurchaseProvider.purchaseProduct(product);
                      if (result.$1 && context.mounted) {
                      } else {
                        if (context.mounted) {}
                      }
                    },
                  );
                } else {
                  showDialog(
                    context: context,
                    builder: (context) => CancelDialog(),
                  );
                }
              },
            ),
            SettingList(
              label: '送信者名',
              subtitle: Text(
                user?.senderName ?? '',
                style: TextStyle(
                  color: kBlackColor,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'SourceHanSansJP-Bold',
                ),
              ),
              trailing: const FaIcon(
                FontAwesomeIcons.pen,
                size: 16,
              ),
              onTap: () {
                Navigator.push(
                  context,
                  PageTransition(
                    type: PageTransitionType.rightToLeft,
                    child: SendSettingNameScreen(
                      userProvider: widget.userProvider,
                    ),
                  ),
                );
              },
            ),
            SettingList(
              label: '送信者QRコード',
              subtitle: Text(
                '※受信者に見せてください',
                style: TextStyle(
                  color: kRedColor,
                  fontSize: 14,
                ),
              ),
              trailing: const FaIcon(
                FontAwesomeIcons.chevronRight,
                size: 16,
              ),
              onTap: () {
                Navigator.push(
                  context,
                  PageTransition(
                    type: PageTransitionType.rightToLeft,
                    child: SendSettingQrScreen(
                      userProvider: widget.userProvider,
                    ),
                  ),
                );
              },
            ),
            SettingList(
              label: '受信者一覧 (${user?.sendMapUsers.length})',
              trailing: const FaIcon(
                FontAwesomeIcons.chevronRight,
                size: 16,
              ),
              onTap: () {
                Navigator.push(
                  context,
                  PageTransition(
                    type: PageTransitionType.rightToLeft,
                    child: SendSettingUsersScreen(
                      userProvider: widget.userProvider,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

void showSubscriptionDialog(
  BuildContext context, {
  required Function(ProductDetails?) result,
}) {
  showModalBottomSheet<bool?>(
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
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Column(
                    children: [
                      Text(
                        'ご利用中のプランの切替',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'SourceHanSansJP-Bold',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'プランを切り替えることで、いくつかの機能が解放されます。',
                    style: TextStyle(
                      color: kBlackColor.withOpacity(0.5),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  LinkText(
                    label: '利用規約を確認',
                    onTap: () async {
                      if (!await launchUrl(Uri.parse(
                        'https://docs.google.com/document/d/18yzTySjHTdCE_VHS6NjAeP8OfTpfqyh5VZjaqBgdP78/edit?usp=sharing',
                      ))) {
                        throw Exception('Could not launch');
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  Column(
                    children: inAppPurchaseProvider.viewProducts.map((product) {
                      print(product.id);
                      return ProductList(
                        product: product,
                        selectedProduct: inAppPurchaseProvider.selectedProduct,
                        onTap: () {
                          inAppPurchaseProvider.selectedProduct = product;
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kBlueColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () async {
                              Navigator.of(context).pop(true);
                            },
                            child: Text(
                              '選択プランに切り替える',
                              style: TextStyle(
                                color: kWhiteColor,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'SourceHanSansJP-Bold',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  LinkText(
                    label: '購入の復元',
                    onTap: () {
                      inAppPurchaseProvider.restorePurchases();
                      Navigator.of(context).pop();
                    },
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
      );
    },
  ).then((value) async {
    if (value != true || !context.mounted) return;
    if (context.read<InAppPurchaseProvider>().selectedProduct == null &&
        context.mounted) {
      return;
    }

    result(
      context.read<InAppPurchaseProvider>().selectedProduct,
    );

    Navigator.pushReplacement(
      context,
      PageTransition(
        type: PageTransitionType.bottomToTop,
        child: HomeScreen(),
      ),
    );
  });
}

class CancelDialog extends StatelessWidget {
  const CancelDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomAlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 8),
          Platform.isIOS
              ? Text(
                  'このプランを解約する場合は、アプリを閉じて、[設定]>[AppleAccount]>[サブスクリプション]から解約を行ってください。',
                )
              : Text(
                  'このプランを解約する場合は、アプリを閉じて、[Playストア]>[お支払いと定期購入]>[定期購入]から解約を行ってください。',
                ),
        ],
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        CustomButton(
          type: ButtonSizeType.sm,
          label: '閉じる',
          labelColor: kWhiteColor,
          backgroundColor: kBlackColor.withOpacity(0.5),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }
}
