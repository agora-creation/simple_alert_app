import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:simple_alert_app/common/style.dart';
import 'package:simple_alert_app/models/user_noticer_group.dart';

class UserNoticerGroupList extends StatelessWidget {
  final UserNoticerGroupModel userNoticerGroup;
  final Function()? onTap;

  const UserNoticerGroupList({
    required this.userNoticerGroup,
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
        title: Text(
          '${userNoticerGroup.name} (${userNoticerGroup.userIds.length})',
        ),
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
