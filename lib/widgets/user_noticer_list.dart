import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:simple_alert_app/common/style.dart';
import 'package:simple_alert_app/models/user_noticer.dart';

class UserNoticerList extends StatelessWidget {
  final UserNoticerModel userNoticer;
  final Function()? onTap;

  const UserNoticerList({
    required this.userNoticer,
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
        color: userNoticer.block ? kRedColor.withOpacity(0.3) : kWhiteColor,
      ),
      child: ListTile(
        title: Text(userNoticer.noticerUserName),
        subtitle: userNoticer.block
            ? Text(
                'ブロックされています',
                style: TextStyle(
                  color: kRedColor,
                  fontSize: 14,
                ),
              )
            : null,
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
