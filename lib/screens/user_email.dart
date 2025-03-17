import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:simple_alert_app/common/style.dart';
import 'package:simple_alert_app/models/user.dart';
import 'package:simple_alert_app/providers/user.dart';
import 'package:simple_alert_app/widgets/custom_text_form_field.dart';

class UserEmailScreen extends StatefulWidget {
  final UserModel user;

  const UserEmailScreen({
    required this.user,
    super.key,
  });

  @override
  State<UserEmailScreen> createState() => _UserEmailScreenState();
}

class _UserEmailScreenState extends State<UserEmailScreen> {
  TextEditingController emailController = TextEditingController();

  @override
  void initState() {
    emailController.text = widget.user.email;
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
          'メールアドレスの変更',
          style: TextStyle(color: kBlackColor),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              String? error = await userProvider.updateEmail(
                email: emailController.text,
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
                  controller: emailController,
                  textInputType: TextInputType.emailAddress,
                  maxLines: 1,
                  label: 'メールアドレス',
                  color: kBlackColor,
                  prefix: Icons.email,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
