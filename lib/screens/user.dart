import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:simple_alert_app/common/functions.dart';
import 'package:simple_alert_app/common/style.dart';
import 'package:simple_alert_app/models/user.dart';
import 'package:simple_alert_app/providers/in_app_purchase.dart';
import 'package:simple_alert_app/providers/user.dart';
import 'package:simple_alert_app/screens/home.dart';
import 'package:simple_alert_app/screens/user_name.dart';
import 'package:simple_alert_app/services/user_send.dart';
import 'package:simple_alert_app/widgets/custom_alert_dialog.dart';
import 'package:simple_alert_app/widgets/custom_button.dart';
import 'package:simple_alert_app/widgets/custom_text_form_field.dart';
import 'package:simple_alert_app/widgets/link_text.dart';
import 'package:simple_alert_app/widgets/product_list.dart';
import 'package:simple_alert_app/widgets/user_list.dart';
import 'package:url_launcher/url_launcher.dart';

class UserScreen extends StatefulWidget {
  final UserProvider userProvider;

  const UserScreen({
    required this.userProvider,
    super.key,
  });

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController telController = TextEditingController();
  int monthSendCount = 0;

  void _init() async {
    monthSendCount = await UserSendService().selectMonthSendCount(
      userId: widget.userProvider.user!.id,
    );
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
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(top: 8, left: 16, right: 16),
        child: Card(
          color: kWhiteColor,
          elevation: 0,
          shape: RoundedRectangleBorder(),
          child: widget.userProvider.loginCheck()
              ? ListView(
                  children: [
                    UserList(
                      label: '名前',
                      subtitle: Text(
                        user?.name ?? '',
                        style: TextStyle(fontSize: 14),
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
                            child: UserNameScreen(
                              userProvider: widget.userProvider,
                            ),
                          ),
                        );
                      },
                    ),
                    UserList(
                      label: '電話番号',
                      subtitle: Text(
                        user?.tel ?? '',
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                    UserList(
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
                      leading: const FaIcon(
                        FontAwesomeIcons.userTag,
                        size: 16,
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
                              final result = await inAppPurchaseProvider
                                  .purchaseProduct(product);
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
                    UserList(
                      label: '今月の送信件数',
                      subtitle: Text(
                        '$monthSendCount件 / ${inAppPurchaseProvider.planMonthLimit}件まで送信可能',
                        style: TextStyle(
                          color: kBlackColor,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'SourceHanSansJP-Bold',
                        ),
                      ),
                      leading: const FaIcon(
                        FontAwesomeIcons.chartSimple,
                        size: 16,
                      ),
                    ),
                    SizedBox(height: 24),
                    Center(
                      child: LinkText(
                        label: 'ログアウト',
                        color: kRedColor,
                        onTap: () => showDialog(
                          context: context,
                          builder: (context) => LogoutDialog(
                            userProvider: widget.userProvider,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 40),
                  ],
                )
              : GestureDetector(
                  onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 24,
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          const SizedBox(height: 16),
                          Text('本アプリを利用するには、電話番号での認証が必要です。'),
                          const SizedBox(height: 16),
                          CustomTextFormField(
                            controller: telController,
                            textInputType: TextInputType.phone,
                            maxLines: 1,
                            label: '電話番号',
                            color: kBlackColor,
                            prefix: Icons.phone,
                          ),
                          const SizedBox(height: 16),
                          CustomButton(
                            type: ButtonSizeType.lg,
                            label: '認証する',
                            labelColor: kWhiteColor,
                            backgroundColor: kBlueColor,
                            onPressed: () async {
                              final result = await widget.userProvider.signIn(
                                tel: telController.text,
                              );
                              if (result.error != null) {
                                if (!mounted) return;
                                showMessage(context, result.error!, false);
                                return;
                              }
                              if (result.autoAuth) {
                                await widget.userProvider.reload();
                                if (!mounted) return;
                                Navigator.pushReplacement(
                                  context,
                                  PageTransition(
                                    type: PageTransitionType.bottomToTop,
                                    child: HomeScreen(currentIndex: 2),
                                  ),
                                );
                              } else {
                                if (!mounted) return;
                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (context) => SmsCodeDialog(
                                    userProvider: widget.userProvider,
                                    tel: telController.text,
                                  ),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}

class SmsCodeDialog extends StatefulWidget {
  final UserProvider userProvider;
  final String tel;

  const SmsCodeDialog({
    required this.userProvider,
    required this.tel,
    super.key,
  });

  @override
  State<SmsCodeDialog> createState() => _SmsCodeDialogState();
}

class _SmsCodeDialogState extends State<SmsCodeDialog> {
  TextEditingController smsCodeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return CustomAlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 8),
          Text('SMS宛に届いた認証コードを入力してください'),
          SizedBox(height: 8),
          CustomTextFormField(
            controller: smsCodeController,
            textInputType: TextInputType.number,
            maxLines: 1,
            label: '認証コード',
            color: kBlackColor,
            prefix: Icons.phone_callback,
          ),
        ],
      ),
      actions: [
        CustomButton(
          type: ButtonSizeType.sm,
          label: 'キャンセル',
          labelColor: kWhiteColor,
          backgroundColor: kBlackColor.withOpacity(0.5),
          onPressed: () => Navigator.pop(context),
        ),
        CustomButton(
          type: ButtonSizeType.sm,
          label: '認証する',
          labelColor: kWhiteColor,
          backgroundColor: kBlueColor,
          onPressed: () async {
            String? error = await widget.userProvider.signInConf(
              tel: widget.tel,
              smsCode: smsCodeController.text,
            );
            if (error != null) {
              if (!mounted) return;
              showMessage(context, error, false);
              return;
            }
            await widget.userProvider.reload();
            if (!mounted) return;
            Navigator.pushReplacement(
              context,
              PageTransition(
                type: PageTransitionType.bottomToTop,
                child: HomeScreen(currentIndex: 2),
              ),
            );
          },
        ),
      ],
    );
  }
}

class LogoutDialog extends StatelessWidget {
  final UserProvider userProvider;

  const LogoutDialog({
    required this.userProvider,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return CustomAlertDialog(
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 8),
          Text(
            '本当にログアウトしますか？',
            style: TextStyle(color: kRedColor),
          ),
        ],
      ),
      actions: [
        CustomButton(
          type: ButtonSizeType.sm,
          label: 'キャンセル',
          labelColor: kWhiteColor,
          backgroundColor: kBlackColor.withOpacity(0.5),
          onPressed: () => Navigator.pop(context),
        ),
        CustomButton(
          type: ButtonSizeType.sm,
          label: 'ログアウト',
          labelColor: kWhiteColor,
          backgroundColor: kRedColor,
          onPressed: () async {
            await userProvider.logout();
            Navigator.pushReplacement(
              context,
              PageTransition(
                type: PageTransitionType.bottomToTop,
                child: HomeScreen(currentIndex: 2),
              ),
            );
          },
        ),
      ],
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
        child: HomeScreen(currentIndex: 2),
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
