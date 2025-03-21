import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:page_transition/page_transition.dart';
import 'package:restart_app/restart_app.dart';
import 'package:simple_alert_app/common/functions.dart';
import 'package:simple_alert_app/common/style.dart';
import 'package:simple_alert_app/providers/user.dart';
import 'package:simple_alert_app/screens/user_sender_name.dart';
import 'package:simple_alert_app/widgets/custom_button.dart';
import 'package:simple_alert_app/widgets/custom_text_form_field.dart';
import 'package:simple_alert_app/widgets/link_text.dart';
import 'package:simple_alert_app/widgets/user_list.dart';

class UserSenderScreen extends StatefulWidget {
  final UserProvider userProvider;

  const UserSenderScreen({
    required this.userProvider,
    super.key,
  });

  @override
  State<UserSenderScreen> createState() => _UserSenderScreenState();
}

class _UserSenderScreenState extends State<UserSenderScreen> {
  TextEditingController senderNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kWhiteColor,
      appBar: AppBar(
        backgroundColor: kWhiteColor,
        leading: IconButton(
          icon: const FaIcon(FontAwesomeIcons.chevronLeft),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.userProvider.user!.isSender ? '送信者情報' : '送信者として登録',
          style: TextStyle(color: kBlackColor),
        ),
        actions: [
          widget.userProvider.user!.isSender
              ? TextButton(
                  onPressed: () async {
                    String? error = await widget.userProvider.senderReset();
                    if (error != null) {
                      if (!mounted) return;
                      showMessage(context, error, false);
                      return;
                    }
                    await widget.userProvider.reload();
                    Restart.restartApp(
                      notificationTitle: 'アプリの再起動',
                      notificationBody: 'ログイン情報を再読み込みするため、アプリを再起動します。',
                    );
                  },
                  child: Text(
                    '登録を解除',
                    style: TextStyle(color: kRedColor),
                  ),
                )
              : Container(),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        behavior: HitTestBehavior.opaque,
        child: SafeArea(
          child: widget.userProvider.user!.isSender
              ? Column(
                  children: [
                    UserList(
                      label: '送信者番号',
                      subtitle: Text(
                        widget.userProvider.user!.senderNumber,
                        style: TextStyle(fontSize: 14),
                      ),
                      trailing: LinkText(
                        label: '共有',
                        onTap: () {},
                      ),
                    ),
                    UserList(
                      label: '送信者名',
                      subtitle: Text(
                        widget.userProvider.user!.senderName,
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
                            child: UserSenderNameScreen(
                              userProvider: widget.userProvider,
                            ),
                          ),
                        );
                      },
                    ),
                    UserList(
                      label: '登録プラン',
                      subtitle: Text(
                        'Aプラン(300名まで)',
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                )
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      CustomTextFormField(
                        controller: senderNameController,
                        textInputType: TextInputType.name,
                        maxLines: 1,
                        label: '送信者名',
                        color: kBlackColor,
                        prefix: Icons.account_box,
                      ),
                      const SizedBox(height: 16),
                      CustomButton(
                        type: ButtonSizeType.lg,
                        label: 'フリープラン',
                        labelColor: kWhiteColor,
                        backgroundColor: kBlueColor,
                        onPressed: () async {
                          String? error =
                              await widget.userProvider.senderRegistration(
                            senderName: senderNameController.text,
                          );
                          if (error != null) {
                            if (!mounted) return;
                            showMessage(context, error, false);
                            return;
                          }
                          await widget.userProvider.reload();
                          Restart.restartApp(
                            notificationTitle: 'アプリの再起動',
                            notificationBody: 'ログイン情報を再読み込みするため、アプリを再起動します。',
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      CustomButton(
                        type: ButtonSizeType.lg,
                        label: '900円プラン',
                        labelColor: kWhiteColor,
                        backgroundColor: kBlueColor,
                        onPressed: () async {},
                      ),
                      const SizedBox(height: 16),
                      CustomButton(
                        type: ButtonSizeType.lg,
                        label: '1800円プラン',
                        labelColor: kWhiteColor,
                        backgroundColor: kBlueColor,
                        onPressed: () async {},
                      ),
                      const SizedBox(height: 16),
                      CustomButton(
                        type: ButtonSizeType.lg,
                        label: '3000円プラン',
                        labelColor: kWhiteColor,
                        backgroundColor: kBlueColor,
                        onPressed: () async {},
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
