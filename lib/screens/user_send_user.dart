import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:simple_alert_app/common/style.dart';
import 'package:simple_alert_app/models/send_user.dart';
import 'package:simple_alert_app/models/user.dart';
import 'package:simple_alert_app/widgets/custom_check_list.dart';

class UserSendUserScreen extends StatefulWidget {
  final UserModel user;

  const UserSendUserScreen({
    required this.user,
    super.key,
  });

  @override
  State<UserSendUserScreen> createState() => _UserSendUserScreenState();
}

class _UserSendUserScreenState extends State<UserSendUserScreen> {
  List<SendUserModel> sendUsers = [];
  List<SendUserModel> deleteSendUsers = [];

  void _reloadSendUsers(UserModel user) {
    sendUsers = user.sendUsers;
    setState(() {});
  }

  @override
  void initState() {
    sendUsers = widget.user.sendUsers;
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
          deleteSendUsers.isNotEmpty
              ? TextButton(
                  onPressed: () {},
                  child: Text(
                    '選択項目を削除',
                    style: TextStyle(color: kRedColor),
                  ),
                )
              : Container(),
        ],
      ),
      body: SafeArea(
        child: sendUsers.isNotEmpty
            ? ListView.builder(
                itemCount: sendUsers.length,
                itemBuilder: (context, index) {
                  SendUserModel sendUser = sendUsers[index];
                  bool value = deleteSendUsers.contains(sendUser);
                  return CustomCheckList(
                    label: sendUser.name,
                    subtitle: Text(
                      sendUser.email,
                      style: TextStyle(fontSize: 14),
                    ),
                    value: value,
                    onChanged: (value) {
                      if (!deleteSendUsers.contains(sendUser)) {
                        deleteSendUsers.add(sendUser);
                      } else {
                        deleteSendUsers.remove(sendUser);
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
        onPressed: () {},
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
