import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:simple_alert_app/common/style.dart';
import 'package:simple_alert_app/models/sender_user.dart';
import 'package:simple_alert_app/models/user.dart';
import 'package:simple_alert_app/widgets/custom_check_list.dart';

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
        child: senderUsers.isNotEmpty
            ? ListView.builder(
                itemCount: senderUsers.length,
                itemBuilder: (context, index) {
                  SenderUserModel senderUser = senderUsers[index];
                  return CustomCheckList(
                    label: senderUser.name,
                    value: false,
                    onChanged: (value) {},
                    activeColor: kRedColor,
                  );
                },
              )
            : Center(child: Text('受信先はありません')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
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
