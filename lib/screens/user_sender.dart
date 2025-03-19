import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:simple_alert_app/common/functions.dart';
import 'package:simple_alert_app/common/style.dart';
import 'package:simple_alert_app/models/user.dart';
import 'package:simple_alert_app/providers/user.dart';
import 'package:simple_alert_app/screens/user_sender_name.dart';
import 'package:simple_alert_app/widgets/custom_button.dart';
import 'package:simple_alert_app/widgets/custom_text_form_field.dart';
import 'package:simple_alert_app/widgets/link_text.dart';
import 'package:simple_alert_app/widgets/user_list.dart';

class UserSenderScreen extends StatefulWidget {
  final UserModel user;

  const UserSenderScreen({
    required this.user,
    super.key,
  });

  @override
  State<UserSenderScreen> createState() => _UserSenderScreenState();
}

class _UserSenderScreenState extends State<UserSenderScreen> {
  TextEditingController senderNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    return Scaffold(
      backgroundColor: kWhiteColor,
      appBar: AppBar(
        backgroundColor: kWhiteColor,
        leading: IconButton(
          icon: const FaIcon(FontAwesomeIcons.chevronLeft),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.user.isSender ? '送信者情報' : '送信者として登録',
          style: TextStyle(color: kBlackColor),
        ),
        actions: [
          widget.user.isSender
              ? TextButton(
                  onPressed: () async {
                    String? error = await userProvider.senderReset();
                    if (error != null) {
                      if (!mounted) return;
                      showMessage(context, error, false);
                      return;
                    }
                    await userProvider.reload();
                    if (!mounted) return;
                    Navigator.pop(context);
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
          child: widget.user.isSender
              ? Column(
                  children: [
                    UserList(
                      label: '送信者番号',
                      subtitle: Text(
                        widget.user.senderNumber,
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
                        widget.user.senderName,
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
                              user: userProvider.user!,
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
                        label: '登録する',
                        labelColor: kBlackColor,
                        backgroundColor: kBackgroundColor,
                        onPressed: () async {
                          String? error = await userProvider.senderRegistration(
                            senderName: senderNameController.text,
                          );
                          if (error != null) {
                            if (!mounted) return;
                            showMessage(context, error, false);
                            return;
                          }
                          await userProvider.reload();
                          if (!mounted) return;
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
