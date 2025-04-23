import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:simple_alert_app/common/functions.dart';
import 'package:simple_alert_app/common/style.dart';
import 'package:simple_alert_app/providers/user.dart';
import 'package:simple_alert_app/widgets/custom_text_form_field.dart';

class SendSettingGroupAddScreen extends StatefulWidget {
  final UserProvider userProvider;

  const SendSettingGroupAddScreen({
    required this.userProvider,
    super.key,
  });

  @override
  State<SendSettingGroupAddScreen> createState() =>
      _SendSettingGroupAddScreenState();
}

class _SendSettingGroupAddScreenState extends State<SendSettingGroupAddScreen> {
  TextEditingController nameController = TextEditingController();

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
          'グループの追加',
          style: TextStyle(color: kBlackColor),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              String? error = await widget.userProvider.addUserNoticerGroup(
                name: nameController.text,
              );
              if (error != null) {
                if (!mounted) return;
                showMessage(context, error, false);
                return;
              }
              if (!mounted) return;
              Navigator.pop(context);
            },
            child: Text(
              '保存',
              style: TextStyle(color: kBlueColor),
            ),
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
                  controller: nameController,
                  textInputType: TextInputType.name,
                  maxLines: 1,
                  label: 'グループ名',
                  color: kBlackColor,
                  prefix: Icons.account_box,
                  fillColor: kBlackColor.withOpacity(0.1),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
