import 'package:flutter/material.dart';
import 'package:simple_alert_app/common/style.dart';
import 'package:simple_alert_app/models/send_user.dart';

class SendUserList extends StatelessWidget {
  final SendUserModel sendUser;

  const SendUserList({
    required this.sendUser,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: kBlackColor.withOpacity(0.5)),
        ),
      ),
      child: ListTile(
        title: Text(sendUser.name),
        trailing: Text(
          sendUser.answer,
          style: TextStyle(
            color: kRedColor,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'SourceHanSansJP-Bold',
          ),
        ),
      ),
    );
  }
}
