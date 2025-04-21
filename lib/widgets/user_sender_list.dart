import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:simple_alert_app/common/style.dart';
import 'package:simple_alert_app/models/user_sender.dart';

class UserSenderList extends StatelessWidget {
  final UserSenderModel userSender;
  final Function()? onTap;

  const UserSenderList({
    required this.userSender,
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
      ),
      child: ListTile(
        title: Text(userSender.senderUserName),
        trailing: onTap != null
            ? const FaIcon(
                FontAwesomeIcons.chevronRight,
                size: 16,
              )
            : null,
        onTap: onTap,
      ),
    );
  }
}
