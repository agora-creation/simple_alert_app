import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:simple_alert_app/common/functions.dart';
import 'package:simple_alert_app/common/style.dart';
import 'package:simple_alert_app/models/user_notice.dart';
import 'package:simple_alert_app/services/user_notice.dart';

class UserNoticeDetailScreen extends StatefulWidget {
  final UserNoticeModel userNotice;

  const UserNoticeDetailScreen({
    required this.userNotice,
    super.key,
  });

  @override
  State<UserNoticeDetailScreen> createState() => _UserNoticeDetailScreenState();
}

class _UserNoticeDetailScreenState extends State<UserNoticeDetailScreen> {
  void _init() {
    if (!widget.userNotice.read) {
      UserNoticeService().update({
        'id': widget.userNotice.id,
        'userId': widget.userNotice.userId,
        'read': true,
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _init();
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
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '受信日時: ${dateText('yyyy/MM/dd HH:mm', widget.userNotice.createdAt)}',
                        style: TextStyle(
                          color: kBlackColor.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        '送信者名: ${widget.userNotice.createdUserName}',
                        style: TextStyle(
                          color: kBlackColor.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Divider(height: 0, color: kBlackColor.withOpacity(0.5)),
                const SizedBox(height: 8),
                Text(
                  widget.userNotice.title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'SourceHanSansJP-Bold',
                  ),
                ),
                const SizedBox(height: 8),
                Text(widget.userNotice.content),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
