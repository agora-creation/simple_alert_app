import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:simple_alert_app/common/functions.dart';
import 'package:simple_alert_app/common/style.dart';
import 'package:simple_alert_app/models/user_send.dart';
import 'package:simple_alert_app/widgets/alert_chip.dart';

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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: kBlackColor.withOpacity(0.5)),
          ),
          color: userSend.draft ? kRedColor.withOpacity(0.3) : kWhiteColor,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 8,
            horizontal: 16,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userSend.title,
                    style: TextStyle(
                      color: kBlackColor,
                      fontSize: 18,
                    ),
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  userSend.draft
                      ? Container()
                      : Text(
                          '送信日時: ${dateText('yyyy/MM/dd HH:mm', userSend.createdAt)}',
                          style: TextStyle(
                            color: kBlackColor.withOpacity(0.8),
                            fontSize: 14,
                          ),
                        ),
                  userSend.draft
                      ? Container()
                      : Text(
                          '送信件数: ${userSend.sendUsers.length}件',
                          style: TextStyle(
                            color: kBlackColor.withOpacity(0.8),
                            fontSize: 14,
                          ),
                        ),
                ],
              ),
              userSend.draft
                  ? Text(
                      '下書き中',
                      style: TextStyle(
                        color: kRedColor,
                        fontSize: 14,
                      ),
                    )
                  : userSend.isChoice
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
