import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:simple_alert_app/common/functions.dart';
import 'package:simple_alert_app/common/style.dart';
import 'package:simple_alert_app/models/user_send.dart';

class UserSendList extends StatelessWidget {
  final UserSendModel userSend;
  final Function()? onTap;

  const UserSendList({
    required this.userSend,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: kBlackColor.withOpacity(0.5)),
        ),
        color: userSend.draft ? kRedColor.withOpacity(0.3) : kWhiteColor,
      ),
      child: ListTile(
        title: Text(userSend.title),
        subtitle: userSend.draft
            ? null
            : Text(
                '送信日時: ${dateText('yyyy/MM/dd HH:mm', userSend.sendAt)}',
                style: TextStyle(
                  color: kBlackColor.withOpacity(0.8),
                  fontSize: 14,
                ),
              ),
        trailing: userSend.draft
            ? Text(
                '未送信',
                style: TextStyle(
                  color: kRedColor,
                  fontSize: 14,
                ),
              )
            : const FaIcon(
                FontAwesomeIcons.chevronRight,
                size: 16,
              ),
        onTap: onTap,
      ),
    );
  }
}
