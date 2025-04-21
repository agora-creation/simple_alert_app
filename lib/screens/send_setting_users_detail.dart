import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:simple_alert_app/common/functions.dart';
import 'package:simple_alert_app/common/style.dart';
import 'package:simple_alert_app/models/user_noticer.dart';
import 'package:simple_alert_app/providers/user.dart';
import 'package:simple_alert_app/widgets/custom_alert_dialog.dart';
import 'package:simple_alert_app/widgets/custom_button.dart';

class SendSettingUsersDetailScreen extends StatelessWidget {
  final UserProvider userProvider;
  final UserNoticerModel userNoticer;

  const SendSettingUsersDetailScreen({
    required this.userProvider,
    required this.userNoticer,
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
        actions: [
          TextButton(
            onPressed: () => showDialog(
              context: context,
              builder: (context) => DelDialog(
                userProvider: userProvider,
                userNoticer: userNoticer,
              ),
            ),
            child: Text(
              '削除',
              style: TextStyle(color: kRedColor),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              Container(
                color: kMsgBgColor,
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      '受信者名',
                      style: TextStyle(fontSize: 14),
                    ),
                    Text(
                      userNoticer.noticerUserName,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'SourceHanSansJP-Bold',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DelDialog extends StatelessWidget {
  final UserProvider userProvider;
  final UserNoticerModel userNoticer;

  const DelDialog({
    required this.userProvider,
    required this.userNoticer,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return CustomAlertDialog(
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 8),
          Text(
            '本当に削除しますか？',
            style: TextStyle(color: kRedColor),
          ),
        ],
      ),
      actions: [
        CustomButton(
          type: ButtonSizeType.sm,
          label: 'キャンセル',
          labelColor: kWhiteColor,
          backgroundColor: kBlackColor.withOpacity(0.5),
          onPressed: () => Navigator.pop(context),
        ),
        CustomButton(
          type: ButtonSizeType.sm,
          label: '削除する',
          labelColor: kWhiteColor,
          backgroundColor: kRedColor,
          onPressed: () async {
            String? error = await userProvider.removeUserNoticer(
              userNoticer: userNoticer,
            );
            if (error != null) {
              showMessage(context, error, false);
              return;
            }
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}
