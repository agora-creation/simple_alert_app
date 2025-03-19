import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:simple_alert_app/common/functions.dart';
import 'package:simple_alert_app/common/style.dart';
import 'package:simple_alert_app/models/map_notice_user.dart';
import 'package:simple_alert_app/models/user.dart';
import 'package:simple_alert_app/providers/user.dart';
import 'package:simple_alert_app/widgets/custom_alert_dialog.dart';
import 'package:simple_alert_app/widgets/custom_button.dart';
import 'package:simple_alert_app/widgets/custom_check_list.dart';
import 'package:simple_alert_app/widgets/custom_text_form_field.dart';

class UserMapNoticeUserScreen extends StatefulWidget {
  final UserModel user;

  const UserMapNoticeUserScreen({
    required this.user,
    super.key,
  });

  @override
  State<UserMapNoticeUserScreen> createState() =>
      _UserMapNoticeUserScreenState();
}

class _UserMapNoticeUserScreenState extends State<UserMapNoticeUserScreen> {
  List<MapNoticeUserModel> mapNoticeUsers = [];
  List<MapNoticeUserModel> deleteMapNoticeUsers = [];

  void _reload(UserModel user) {
    mapNoticeUsers = user.mapNoticeUsers;
    setState(() {});
  }

  @override
  void initState() {
    mapNoticeUsers = widget.user.mapNoticeUsers;
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
          deleteMapNoticeUsers.isNotEmpty
              ? TextButton(
                  onPressed: () => showDialog(
                    context: context,
                    builder: (context) => DelDialog(
                      deleteMapNoticeUsers: deleteMapNoticeUsers,
                      reload: _reload,
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
        child: mapNoticeUsers.isNotEmpty
            ? ListView.builder(
                itemCount: mapNoticeUsers.length,
                itemBuilder: (context, index) {
                  MapNoticeUserModel mapNoticeUser = mapNoticeUsers[index];
                  bool value = deleteMapNoticeUsers.contains(mapNoticeUser);
                  return CustomCheckList(
                    label: mapNoticeUser.senderName,
                    subtitle: Text(
                      '送信者番号: ${mapNoticeUser.senderNumber}',
                      style: TextStyle(fontSize: 14),
                    ),
                    value: value,
                    onChanged: (value) {
                      if (!deleteMapNoticeUsers.contains(mapNoticeUser)) {
                        deleteMapNoticeUsers.add(mapNoticeUser);
                      } else {
                        deleteMapNoticeUsers.remove(mapNoticeUser);
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
            reload: _reload,
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
  final Function(UserModel) reload;

  const AddDialog({
    required this.reload,
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
            String? error = await userProvider.addMapNoticeUsers(
              senderNumber: senderNumberController.text,
            );
            if (error != null) {
              if (!mounted) return;
              showMessage(context, error, false);
              return;
            }
            await userProvider.reload();
            widget.reload(userProvider.user!);
            if (!mounted) return;
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}

class DelDialog extends StatelessWidget {
  final List<MapNoticeUserModel> deleteMapNoticeUsers;
  final Function(UserModel) reload;

  const DelDialog({
    required this.deleteMapNoticeUsers,
    required this.reload,
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
            String? error = await userProvider.removeMapNoticeUsers(
              deleteMapNoticeUsers: deleteMapNoticeUsers,
            );
            if (error != null) {
              showMessage(context, error, false);
              return;
            }
            await userProvider.reload();
            reload(userProvider.user!);
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}
