import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:simple_alert_app/common/functions.dart';
import 'package:simple_alert_app/common/style.dart';
import 'package:simple_alert_app/providers/user.dart';
import 'package:simple_alert_app/screens/home.dart';
import 'package:simple_alert_app/widgets/custom_alert_dialog.dart';
import 'package:simple_alert_app/widgets/custom_button.dart';
import 'package:simple_alert_app/widgets/custom_text_form_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController telController = TextEditingController();
  bool buttonDisabled = false;

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    Text(
                      kAppShortName,
                      style: TextStyle(
                        color: kBlackColor,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'SourceHanSansJP-Bold',
                      ),
                    ),
                    Text(
                      '- 通知に特化したアプリ -',
                      style: TextStyle(
                        color: kBlackColor,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      '$kAppShortNameのアプリを利用するには、電話番号によるSMS認証が必要です。',
                      style: TextStyle(fontSize: 14),
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
                      label: '認証コードを送信',
                      labelColor: kWhiteColor,
                      backgroundColor: kBlueColor,
                      onPressed: () async {
                        setState(() {
                          buttonDisabled = true;
                        });
                        final result = await userProvider.signIn(
                          name: nameController.text,
                          tel: telController.text,
                        );
                        if (result.error != null) {
                          if (!mounted) return;
                          setState(() {
                            buttonDisabled = false;
                          });
                          showMessage(context, result.error!, false);
                          return;
                        }
                        if (result.autoAuth) {
                          await userProvider.reload();
                          if (!mounted) return;
                          Navigator.pushReplacement(
                            context,
                            PageTransition(
                              type: PageTransitionType.bottomToTop,
                              child: HomeScreen(),
                            ),
                          );
                        } else {
                          if (!mounted) return;
                          setState(() {
                            buttonDisabled = false;
                          });
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) => SmsCodeDialog(
                              userProvider: userProvider,
                              name: nameController.text,
                              tel: telController.text,
                            ),
                          );
                        }
                      },
                      disabled: buttonDisabled,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SmsCodeDialog extends StatefulWidget {
  final UserProvider userProvider;
  final String name;
  final String tel;

  const SmsCodeDialog({
    required this.userProvider,
    required this.name,
    required this.tel,
    super.key,
  });

  @override
  State<SmsCodeDialog> createState() => _SmsCodeDialogState();
}

class _SmsCodeDialogState extends State<SmsCodeDialog> {
  TextEditingController smsCodeController = TextEditingController();
  bool buttonDisabled = false;

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
            fillColor: kBlackColor.withOpacity(0.1),
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
            setState(() {
              buttonDisabled = true;
            });
            String? error = await widget.userProvider.signInConf(
              name: widget.name,
              tel: widget.tel,
              smsCode: smsCodeController.text,
            );
            if (error != null) {
              if (!mounted) return;
              setState(() {
                buttonDisabled = false;
              });
              showMessage(context, '正しい認証コードを入力してください', false);
              return;
            }
            await widget.userProvider.reload();
            if (!mounted) return;
            Navigator.pushReplacement(
              context,
              PageTransition(
                type: PageTransitionType.bottomToTop,
                child: HomeScreen(),
              ),
            );
          },
          disabled: buttonDisabled,
        ),
      ],
    );
  }
}
