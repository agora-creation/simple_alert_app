import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:simple_alert_app/common/functions.dart';
import 'package:simple_alert_app/common/style.dart';
import 'package:simple_alert_app/models/user.dart';
import 'package:simple_alert_app/providers/user.dart';
import 'package:simple_alert_app/widgets/custom_text_form_field.dart';

class NoticeSettingNameScreen extends StatefulWidget {
  final UserProvider userProvider;

  const NoticeSettingNameScreen({
    required this.userProvider,
    super.key,
  });

  @override
  State<NoticeSettingNameScreen> createState() =>
      _NoticeSettingNameScreenState();
}

class _NoticeSettingNameScreenState extends State<NoticeSettingNameScreen> {
  TextEditingController nameController = TextEditingController();

  @override
  void initState() {
    UserModel user = widget.userProvider.user!;
    nameController.text = user.name;
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
          '名前の変更',
          style: TextStyle(color: kBlackColor),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              String? error = await widget.userProvider.updateName(
                name: nameController.text,
              );
              if (error != null) {
                if (!mounted) return;
                showMessage(context, error, false);
                return;
              }
              await widget.userProvider.reload();
              if (!mounted) return;
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
                  controller: nameController,
                  textInputType: TextInputType.name,
                  maxLines: 1,
                  label: '名前',
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
