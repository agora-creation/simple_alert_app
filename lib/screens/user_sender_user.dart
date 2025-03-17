import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:simple_alert_app/common/style.dart';
import 'package:simple_alert_app/models/sender_user.dart';
import 'package:simple_alert_app/models/user.dart';
import 'package:simple_alert_app/providers/user.dart';
import 'package:simple_alert_app/widgets/custom_alert_dialog.dart';
import 'package:simple_alert_app/widgets/custom_button.dart';
import 'package:simple_alert_app/widgets/custom_check_list.dart';
import 'package:simple_alert_app/widgets/custom_text_form_field.dart';

class UserSenderUserScreen extends StatefulWidget {
  final UserModel user;

  const UserSenderUserScreen({
    required this.user,
    super.key,
  });

  @override
  State<UserSenderUserScreen> createState() => _UserSenderUserScreenState();
}

class _UserSenderUserScreenState extends State<UserSenderUserScreen> {
  List<SenderUserModel> senderUsers = [];
  List<SenderUserModel> deleteSenderUsers = [];

  void _reloadSenderUsers(UserModel user) {
    senderUsers = user.senderUsers;
    setState(() {});
  }

  @override
  void initState() {
    senderUsers = widget.user.senderUsers;
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
          '受信先一覧',
          style: TextStyle(color: kBlackColor),
        ),
        actions: [
          deleteSenderUsers.isNotEmpty
              ? TextButton(
                  onPressed: () => showDialog(
                    context: context,
                    builder: (context) => DelDialog(
                      deleteSenderUsers: deleteSenderUsers,
                      reloadSenderUsers: _reloadSenderUsers,
                    ),
                  ),
                  child: Text(
                    '選択項目を削除',
                    style: TextStyle(color: kRedColor),
                  ),
                )
              : Container(),
        ],
      ),
      body: SafeArea(
        child: senderUsers.isNotEmpty
            ? ListView.builder(
                itemCount: senderUsers.length,
                itemBuilder: (context, index) {
                  SenderUserModel senderUser = senderUsers[index];
                  bool value = deleteSenderUsers.contains(senderUser);
                  return CustomCheckList(
                    label: senderUser.name,
                    subtitle: Text(
                      '送信者番号: ${senderUser.id}',
                      style: TextStyle(fontSize: 14),
                    ),
                    value: value,
                    onChanged: (value) {
                      if (!deleteSenderUsers.contains(senderUser)) {
                        deleteSenderUsers.add(senderUser);
                      } else {
                        deleteSenderUsers.remove(senderUser);
                      }
                      setState(() {});
                    },
                    activeColor: kRedColor,
                  );
                },
              )
            : Center(child: Text('受信先はありません')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showDialog(
          context: context,
          builder: (context) => AddDialog(
            reloadSenderUsers: _reloadSenderUsers,
          ),
        ),
        icon: const FaIcon(
          FontAwesomeIcons.plus,
          color: kWhiteColor,
        ),
        label: Text(
          '受信先を追加',
          style: TextStyle(color: kWhiteColor),
        ),
      ),
    );
  }
}

class AddDialog extends StatefulWidget {
  final Function(UserModel) reloadSenderUsers;

  const AddDialog({
    required this.reloadSenderUsers,
    super.key,
  });

  @override
  State<AddDialog> createState() => _AddDialogState();
}

class _AddDialogState extends State<AddDialog> {
  TextEditingController senderNumberController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    return CustomAlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 8),
          CustomTextFormField(
            controller: senderNumberController,
            textInputType: TextInputType.number,
            maxLines: 1,
            label: '送信者番号',
            color: kBlackColor,
            prefix: Icons.numbers,
          ),
        ],
      ),
      actions: [
        CustomButton(
          type: ButtonSizeType.sm,
          label: 'キャンセル',
          labelColor: kWhiteColor,
          backgroundColor: kBlackColor.withOpacity(0.5),
          onPressed: () => Navigator.pop(context),
        ),
        CustomButton(
          type: ButtonSizeType.sm,
          label: '追加する',
          labelColor: kWhiteColor,
          backgroundColor: kBlueColor,
          onPressed: () async {
            String? error = await userProvider.addSenderUsers(
              senderNumber: senderNumberController.text,
            );
            if (error != null) {
              return;
            }
            await userProvider.reload();
            widget.reloadSenderUsers(userProvider.user!);
            if (!mounted) return;
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}

class DelDialog extends StatelessWidget {
  final List<SenderUserModel> deleteSenderUsers;
  final Function(UserModel) reloadSenderUsers;

  const DelDialog({
    required this.deleteSenderUsers,
    required this.reloadSenderUsers,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    return CustomAlertDialog(
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 8),
          Text(
            '本当に削除しますか？',
            style: TextStyle(color: kRedColor),
          ),
        ],
      ),
      actions: [
        CustomButton(
          type: ButtonSizeType.sm,
          label: 'キャンセル',
          labelColor: kWhiteColor,
          backgroundColor: kBlackColor.withOpacity(0.5),
          onPressed: () => Navigator.pop(context),
        ),
        CustomButton(
          type: ButtonSizeType.sm,
          label: '削除する',
          labelColor: kWhiteColor,
          backgroundColor: kRedColor,
          onPressed: () async {
            String? error = await userProvider.removeSenderUsers(
              deleteSenderUsers: deleteSenderUsers,
            );
            if (error != null) {
              return;
            }
            await userProvider.reload();
            reloadSenderUsers(userProvider.user!);
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}
