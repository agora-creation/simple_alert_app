import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:restart_app/restart_app.dart';
import 'package:simple_alert_app/common/functions.dart';
import 'package:simple_alert_app/common/style.dart';
import 'package:simple_alert_app/models/user.dart';
import 'package:simple_alert_app/providers/in_app_purchase.dart';
import 'package:simple_alert_app/providers/user.dart';
import 'package:simple_alert_app/screens/user_email.dart';
import 'package:simple_alert_app/screens/user_name.dart';
import 'package:simple_alert_app/screens/user_password.dart';
import 'package:simple_alert_app/widgets/custom_alert_dialog.dart';
import 'package:simple_alert_app/widgets/custom_button.dart';
import 'package:simple_alert_app/widgets/custom_text_form_field.dart';
import 'package:simple_alert_app/widgets/link_text.dart';
import 'package:simple_alert_app/widgets/sign_panel.dart';
import 'package:simple_alert_app/widgets/user_list.dart';

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
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
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
                      label: 'メールアドレス',
                      subtitle: Text(
                        user?.email ?? '',
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
                            child: UserEmailScreen(
                              userProvider: widget.userProvider,
                            ),
                          ),
                        );
                      },
                    ),
                    UserList(
                      label: 'パスワード',
                      subtitle: Text(
                        '********',
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
                            child: UserPasswordScreen(
                              userProvider: widget.userProvider,
                            ),
                          ),
                        );
                      },
                    ),
                    UserList(
                      label: 'ご利用中のプラン',
                      subtitle: Text(
                        user?.subscriptionName() ?? '',
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
                        FontAwesomeIcons.pen,
                        size: 16,
                      ),
                      onTap: () {
                        showSubscriptionDialog(
                          context,
                          productDetailsResult: (details) async {
                            final inAppPurchaseProvider =
                                context.read<InAppPurchaseProvider>();

                            final purchaseResult = await inAppPurchaseProvider
                                .purchaseProduct(details!);

                            if (purchaseResult.$1 && context.mounted) {
                            } else {
                              if (context.mounted) {}
                            }
                          },
                        );
                      },
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
                  child: SignPanel(
                    signUpChild: SingleChildScrollView(
                      child: Column(
                        children: [
                          const SizedBox(height: 16),
                          Text(
                            '本アプリをご利用いただくには、以下の情報のご登録が必要です。あらかじめご了承ください。',
                          ),
                          const SizedBox(height: 16),
                          CustomTextFormField(
                            controller: nameController,
                            textInputType: TextInputType.name,
                            maxLines: 1,
                            label: '名前',
                            color: kBlackColor,
                            prefix: Icons.account_box,
                          ),
                          const SizedBox(height: 8),
                          CustomTextFormField(
                            controller: emailController,
                            textInputType: TextInputType.emailAddress,
                            maxLines: 1,
                            label: 'メールアドレス',
                            color: kBlackColor,
                            prefix: Icons.email,
                          ),
                          const SizedBox(height: 8),
                          CustomTextFormField(
                            controller: passwordController,
                            obscureText: true,
                            textInputType: TextInputType.visiblePassword,
                            maxLines: 1,
                            label: 'パスワード',
                            color: kBlackColor,
                            prefix: Icons.password,
                          ),
                          const SizedBox(height: 16),
                          CustomButton(
                            type: ButtonSizeType.lg,
                            label: '登録して始める',
                            labelColor: kWhiteColor,
                            backgroundColor: kBlueColor,
                            onPressed: () async {
                              String? error =
                                  await widget.userProvider.registration(
                                name: nameController.text,
                                email: emailController.text,
                                password: passwordController.text,
                              );
                              if (error != null) {
                                if (!mounted) return;
                                showMessage(context, error, false);
                                return;
                              }
                              await widget.userProvider.reload();
                              Restart.restartApp(
                                notificationTitle: 'アプリの再起動',
                                notificationBody:
                                    'ログイン情報を再読み込みするため、アプリを再起動します。',
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    signInChild: SingleChildScrollView(
                      child: Column(
                        children: [
                          const SizedBox(height: 16),
                          Text(
                            '本アプリを既にご利用いただいたことがある方は、登録時のメールアドレスやパスワードでログインすることで、情報を引き継いで利用することが可能です。',
                          ),
                          const SizedBox(height: 16),
                          CustomTextFormField(
                            controller: emailController,
                            textInputType: TextInputType.emailAddress,
                            maxLines: 1,
                            label: 'メールアドレス',
                            color: kBlackColor,
                            prefix: Icons.email,
                          ),
                          const SizedBox(height: 8),
                          CustomTextFormField(
                            controller: passwordController,
                            obscureText: true,
                            textInputType: TextInputType.visiblePassword,
                            maxLines: 1,
                            label: 'パスワード',
                            color: kBlackColor,
                            prefix: Icons.password,
                          ),
                          const SizedBox(height: 16),
                          CustomButton(
                            type: ButtonSizeType.lg,
                            label: 'ログイン',
                            labelColor: kWhiteColor,
                            backgroundColor: kBlueColor,
                            onPressed: () async {
                              String? error = await widget.userProvider.login(
                                email: emailController.text,
                                password: passwordController.text,
                              );
                              if (error != null) {
                                if (!mounted) return;
                                showMessage(context, error, false);
                                return;
                              }
                              await widget.userProvider.reload();
                              Restart.restartApp(
                                notificationTitle: 'アプリの再起動',
                                notificationBody:
                                    'ログイン情報を再読み込みするため、アプリを再起動します。',
                              );
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
            Restart.restartApp(
              notificationTitle: 'アプリの再起動',
              notificationBody: 'ログイン情報を再読み込みするため、アプリを再起動します。',
            );
          },
        ),
      ],
    );
  }
}

void showSubscriptionDialog(
  BuildContext context, {
  required Function(ProductDetails?) productDetailsResult,
}) {
  String _getDurationTitleByProductID(String idCode) {
    if (idCode == "subscription_standard") {
      return "per month";
    }
    return "per year";
  }

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
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'SourceHanSansJP-Bold',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('有料プランに切り替えることで、広告を非表示にできたり、送信先の登録上限を増やしたりできます。'),
                  const SizedBox(height: 16),
                  Column(
                    children: [
                      ...List.generate(
                          inAppPurchaseProvider.availableProducts.length,
                          (index) {
                        final plan =
                            inAppPurchaseProvider.availableProducts[index];
                        return GestureDetector(
                          onTap: () {
                            inAppPurchaseProvider.selectedProductDetails = plan;
                          },
                          child: Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.all(10),
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: inAppPurchaseProvider
                                            .selectedProductDetails?.id ==
                                        plan.id
                                    ? Border.all(color: Colors.blue, width: 2)
                                    : null,
                              ),
                              child: ListTile(
                                dense: true,
                                title: Text(
                                  plan.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                subtitle: Text(
                                  plan.description,
                                  style: const TextStyle(
                                    fontSize: 13,
                                  ),
                                ),
                                trailing: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      plan.price,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      _getDurationTitleByProductID(plan.id),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      })
                    ],
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
                              '登録する',
                              style: TextStyle(
                                color: kWhiteColor,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      inAppPurchaseProvider.restorePurchases();
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      '課金の復元',
                      style: TextStyle(color: kBlueColor),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          );
        },
      );
    },
  ).then((value) async {
    if (value != true || !context.mounted) return;
    if (context.read<InAppPurchaseProvider>().selectedProductDetails == null &&
        context.mounted) {
      return;
    }

    productDetailsResult(
        context.read<InAppPurchaseProvider>().selectedProductDetails);
  });
}
