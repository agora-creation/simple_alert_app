import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:simple_alert_app/common/functions.dart';
import 'package:simple_alert_app/common/style.dart';
import 'package:simple_alert_app/models/user.dart';
import 'package:simple_alert_app/providers/user.dart';
import 'package:simple_alert_app/services/user.dart';
import 'package:simple_alert_app/widgets/custom_button.dart';
import 'package:simple_alert_app/widgets/custom_text_form_field.dart';
import 'package:simple_alert_app/widgets/user_list.dart';

class UserNoticeUserAddScreen extends StatefulWidget {
  final UserProvider userProvider;
  final Function(UserModel) reload;

  const UserNoticeUserAddScreen({
    required this.userProvider,
    required this.reload,
    super.key,
  });

  @override
  State<UserNoticeUserAddScreen> createState() =>
      _UserNoticeUserAddScreenState();
}

class _UserNoticeUserAddScreenState extends State<UserNoticeUserAddScreen> {
  TextEditingController emailController = TextEditingController();
  UserModel? selectedUser;

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
          '受信先を登録',
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
                  controller: emailController,
                  textInputType: TextInputType.emailAddress,
                  maxLines: 1,
                  label: 'メールアドレスで検索',
                  color: kBlackColor,
                  prefix: Icons.email,
                ),
                const SizedBox(height: 16),
                CustomButton(
                  type: ButtonSizeType.lg,
                  label: '検索する',
                  labelColor: kWhiteColor,
                  backgroundColor: kBlueColor,
                  onPressed: () async {
                    UserModel? tmpUser = await UserService().selectData(
                      email: emailController.text,
                    );
                    if (tmpUser == null) {
                      if (!mounted) return;
                      showMessage(context, '受信先が見つかりませんでした', false);
                      return;
                    }
                    setState(() {
                      selectedUser = tmpUser;
                    });
                  },
                ),
                const SizedBox(height: 16),
                selectedUser != null
                    ? Column(
                        children: [
                          Text('受信先が見つかりました！'),
                          UserList(
                            label: selectedUser!.name,
                            subtitle: Text(
                              selectedUser!.email,
                              style: TextStyle(fontSize: 14),
                            ),
                            trailing: CustomButton(
                              type: ButtonSizeType.sm,
                              label: '追加',
                              labelColor: kWhiteColor,
                              backgroundColor: kBlueColor,
                              onPressed: () async {
                                String? error =
                                    await widget.userProvider.addNoticeMapUsers(
                                  selectedUser: selectedUser,
                                );
                                if (error != null) {
                                  if (!mounted) return;
                                  showMessage(context, error, false);
                                  return;
                                }
                                await widget.userProvider.reload();
                                widget.reload(widget.userProvider.user!);
                                if (!mounted) return;
                                Navigator.pop(context);
                              },
                            ),
                          ),
                        ],
                      )
                    : Container(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
