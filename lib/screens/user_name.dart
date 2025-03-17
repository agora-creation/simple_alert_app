import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:simple_alert_app/common/style.dart';
import 'package:simple_alert_app/models/user.dart';
import 'package:simple_alert_app/providers/user.dart';
import 'package:simple_alert_app/widgets/custom_text_form_field.dart';

class UserNameScreen extends StatefulWidget {
  final UserModel user;

  const UserNameScreen({
    required this.user,
    super.key,
  });

  @override
  State<UserNameScreen> createState() => _UserNameScreenState();
}

class _UserNameScreenState extends State<UserNameScreen> {
  TextEditingController nameController = TextEditingController();

  @override
  void initState() {
    nameController.text = widget.user.name;
    super.initState();
  }

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
        title: const Text(
          '名前の変更',
          style: TextStyle(color: kBlackColor),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              String? error = await userProvider.updateName(
                name: nameController.text,
              );
              if (error != null) {
                return;
              }
              await userProvider.reload();
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
