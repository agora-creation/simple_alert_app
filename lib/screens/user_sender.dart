import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:simple_alert_app/common/style.dart';
import 'package:simple_alert_app/models/user.dart';
import 'package:simple_alert_app/widgets/custom_button.dart';
import 'package:simple_alert_app/widgets/custom_text_form_field.dart';

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
        title: const Text(
          '送信者として登録',
          style: TextStyle(color: kBlackColor),
        ),
        actions: [
          TextButton(
            onPressed: () {},
            child: Text(
              '登録を解除',
              style: TextStyle(color: kRedColor),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              const SizedBox(height: 16),
              CustomTextFormField(
                controller: TextEditingController(),
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
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}
