import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:simple_alert_app/common/functions.dart';
import 'package:simple_alert_app/common/style.dart';
import 'package:simple_alert_app/models/map_send_user.dart';
import 'package:simple_alert_app/models/user.dart';
import 'package:simple_alert_app/providers/user.dart';
import 'package:simple_alert_app/widgets/custom_alert_dialog.dart';
import 'package:simple_alert_app/widgets/custom_button.dart';
import 'package:simple_alert_app/widgets/custom_check_list.dart';
import 'package:simple_alert_app/widgets/custom_text_form_field.dart';

class UserMapSendUserScreen extends StatefulWidget {
  final UserModel user;

  const UserMapSendUserScreen({
    required this.user,
    super.key,
  });

  @override
  State<UserMapSendUserScreen> createState() => _UserMapSendUserScreenState();
}

class _UserMapSendUserScreenState extends State<UserMapSendUserScreen> {
  List<MapSendUserModel> mapSendUsers = [];
  List<MapSendUserModel> deleteMapSendUsers = [];

  void _reload(UserModel user) {
    mapSendUsers = user.mapSendUsers;
    setState(() {});
  }

  @override
  void initState() {
    mapSendUsers = widget.user.mapSendUsers;
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
          '送信先一覧',
          style: TextStyle(color: kBlackColor),
        ),
        actions: [
          deleteMapSendUsers.isNotEmpty
              ? TextButton(
                  onPressed: () => showDialog(
                    context: context,
                    builder: (context) => DelDialog(
                      deleteMapSendUsers: deleteMapSendUsers,
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
        child: mapSendUsers.isNotEmpty
            ? ListView.builder(
                itemCount: mapSendUsers.length,
                itemBuilder: (context, index) {
                  MapSendUserModel mapSendUser = mapSendUsers[index];
                  bool value = deleteMapSendUsers.contains(mapSendUser);
                  return CustomCheckList(
                    label: mapSendUser.name,
                    subtitle: Text(
                      mapSendUser.email,
                      style: TextStyle(fontSize: 14),
                    ),
                    value: value,
                    onChanged: (value) {
                      if (!deleteMapSendUsers.contains(mapSendUser)) {
                        deleteMapSendUsers.add(mapSendUser);
                      } else {
                        deleteMapSendUsers.remove(mapSendUser);
                      }
                      setState(() {});
                    },
                    activeColor: kRedColor,
                  );
                },
              )
            : Center(child: Text('送信先はありません')),
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
          '送信先を追加',
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
  TextEditingController emailController = TextEditingController();

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
            controller: emailController,
            textInputType: TextInputType.emailAddress,
            maxLines: 1,
            label: 'メールアドレス',
            color: kBlackColor,
            prefix: Icons.email,
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
            String? error = await userProvider.addMapSendUsers(
              email: emailController.text,
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
  final List<MapSendUserModel> deleteMapSendUsers;
  final Function(UserModel) reload;

  const DelDialog({
    required this.deleteMapSendUsers,
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
            String? error = await userProvider.removeMapSendUsers(
              deleteMapSendUsers: deleteMapSendUsers,
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
