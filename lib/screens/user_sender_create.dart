import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:restart_app/restart_app.dart';
import 'package:simple_alert_app/common/functions.dart';
import 'package:simple_alert_app/common/style.dart';
import 'package:simple_alert_app/providers/user.dart';
import 'package:simple_alert_app/widgets/custom_button.dart';
import 'package:simple_alert_app/widgets/custom_text_form_field.dart';

class UserSenderCreateScreen extends StatefulWidget {
  final UserProvider userProvider;

  const UserSenderCreateScreen({
    required this.userProvider,
    super.key,
  });

  @override
  State<UserSenderCreateScreen> createState() => _UserSenderCreateScreenState();
}

class _UserSenderCreateScreenState extends State<UserSenderCreateScreen> {
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
          '送信者として登録',
          style: TextStyle(color: kBlackColor),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        behavior: HitTestBehavior.opaque,
        child: SafeArea(
          child: Padding(
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
