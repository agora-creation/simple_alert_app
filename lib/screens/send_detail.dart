import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:simple_alert_app/common/functions.dart';
import 'package:simple_alert_app/common/style.dart';
import 'package:simple_alert_app/models/user_send.dart';
import 'package:simple_alert_app/widgets/custom_alert_dialog.dart';
import 'package:simple_alert_app/widgets/link_text.dart';

class SendDetailScreen extends StatelessWidget {
  final UserSendModel userSend;

  const SendDetailScreen({
    required this.userSend,
    super.key,
  });

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
                      '送信日時: ${dateText('yyyy/MM/dd HH:mm', userSend.createdAt)}',
                      style: TextStyle(
                        color: kBlackColor.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                    LinkText(
                      label: '送信先を確認',
                      onTap: () => showDialog(
                        context: context,
                        builder: (context) => SendUsersDialog(
                          userSend: userSend,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    color: kMsgBgColor,
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          userSend.title,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'SourceHanSansJP-Bold',
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(userSend.content),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SendUsersDialog extends StatelessWidget {
  final UserSendModel userSend;

  const SendUsersDialog({
    required this.userSend,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return CustomAlertDialog(
      contentPadding: EdgeInsets.zero,
      content: Container(
        decoration: BoxDecoration(
          border: Border.symmetric(
            horizontal: BorderSide(color: kBlackColor.withOpacity(0.5)),
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: userSend.sendMapUsers.map((mapUser) {
              return Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: kBlackColor.withOpacity(0.5)),
                  ),
                ),
                child: ListTile(title: Text(mapUser.name)),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
