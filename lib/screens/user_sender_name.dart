import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:simple_alert_app/common/style.dart';
import 'package:simple_alert_app/models/user.dart';
import 'package:simple_alert_app/widgets/custom_text_form_field.dart';

class UserSenderNameScreen extends StatefulWidget {
  final UserModel user;

  const UserSenderNameScreen({
    required this.user,
    super.key,
  });

  @override
  State<UserSenderNameScreen> createState() => _UserSenderNameScreenState();
}

class _UserSenderNameScreenState extends State<UserSenderNameScreen> {
  TextEditingController senderNameController = TextEditingController();

  @override
  void initState() {
    senderNameController.text = widget.user.senderName;
    super.initState();
  }

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
          '送信者名の変更',
          style: TextStyle(color: kBlackColor),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('保存'),
          ),
        ],
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
