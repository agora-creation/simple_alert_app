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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: kBlackColor.withOpacity(0.5),
            ),
          ),
          color: userNotice.read ? kWhiteColor : kRedColor.withOpacity(0.3),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 10,
            horizontal: 20,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  userNotice.fileName != ''
                      ? Padding(
                          padding: const EdgeInsets.only(right: 16),
                          child: FaIcon(
                            FontAwesomeIcons.file,
                            color: kBlueColor,
                          ),
                        )
                      : Container(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userNotice.title,
                        style: TextStyle(
                          color: kBlackColor,
                          fontSize: 18,
                        ),
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      Text(
                        '受信日時: ${dateText('yyyy/MM/dd HH:mm', userNotice.createdAt)}',
                        style: TextStyle(
                          color: kBlackColor.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        '送信者名: ${userNotice.createdUserName}',
                        style: TextStyle(
                          color: kBlackColor.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              userNotice.isChoice
                  ? AlertChip('回答求')
                  : const FaIcon(
                      FontAwesomeIcons.chevronRight,
                      size: 16,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
