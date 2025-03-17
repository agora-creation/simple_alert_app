import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:simple_alert_app/common/style.dart';
import 'package:simple_alert_app/models/user.dart';

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
          TextButton(
            onPressed: () {},
            child: Text(
              '選択項目を削除',
              style: TextStyle(color: kRedColor),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView.builder(
          itemCount: 10,
          itemBuilder: (context, index) {
            return Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: kBlackColor.withOpacity(0.5),
                  ),
                ),
              ),
              child: CheckboxListTile(
                title: Text('受信太郎'),
                value: true,
                onChanged: (value) {},
                activeColor: kRedColor,
              ),
            );
          },
        ),
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
