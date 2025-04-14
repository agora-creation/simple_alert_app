import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:simple_alert_app/common/functions.dart';
import 'package:simple_alert_app/common/style.dart';
import 'package:simple_alert_app/models/user.dart';
import 'package:simple_alert_app/providers/user.dart';
import 'package:simple_alert_app/widgets/custom_text_form_field.dart';

class SendSettingNameScreen extends StatefulWidget {
  final UserProvider userProvider;

  const SendSettingNameScreen({
    required this.userProvider,
    super.key,
  });

  @override
  State<SendSettingNameScreen> createState() => _SendSettingNameScreenState();
}

class _SendSettingNameScreenState extends State<SendSettingNameScreen> {
  TextEditingController senderNameController = TextEditingController();

  @override
  void initState() {
    UserModel user = widget.userProvider.user!;
    senderNameController.text = user.senderName;
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
            onPressed: () async {
              String? error = await widget.userProvider.updateSenderName(
                senderName: senderNameController.text,
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
                  controller: senderNameController,
                  textInputType: TextInputType.name,
                  maxLines: 1,
                  label: '送信者名',
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
