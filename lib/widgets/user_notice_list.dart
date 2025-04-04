import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:simple_alert_app/common/functions.dart';
import 'package:simple_alert_app/common/style.dart';
import 'package:simple_alert_app/models/user_notice.dart';
import 'package:simple_alert_app/widgets/alert_chip.dart';

class UserNoticeList extends StatelessWidget {
  final UserNoticeModel userNotice;
  final Function()? onTap;

  const UserNoticeList({
    required this.userNotice,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: kBlackColor.withOpacity(0.5),
          ),
        ),
        color: userNotice.read ? kWhiteColor : kRedColor.withOpacity(0.3),
      ),
      child: ListTile(
        title: Text(
          userNotice.title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: 'SourceHanSansJP-Bold',
          ),
          softWrap: false,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        subtitle: Text(
          '受信日時: ${dateText('yyyy/MM/dd HH:mm', userNotice.createdAt)}',
          style: TextStyle(
            color: kBlackColor.withOpacity(0.8),
            fontSize: 14,
          ),
        ),
        trailing: userNotice.isChoice
            ? AlertChip('回答求')
            : const FaIcon(
                FontAwesomeIcons.chevronRight,
                size: 16,
              ),
        onTap: onTap,
      ),
    );
  }
}
