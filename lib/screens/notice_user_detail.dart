import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:simple_alert_app/common/functions.dart';
import 'package:simple_alert_app/common/style.dart';
import 'package:simple_alert_app/models/user_sender.dart';
import 'package:simple_alert_app/providers/user.dart';
import 'package:simple_alert_app/widgets/alert_bar.dart';
import 'package:simple_alert_app/widgets/custom_alert_dialog.dart';
import 'package:simple_alert_app/widgets/custom_button.dart';

class NoticeUserDetailScreen extends StatelessWidget {
  final UserProvider userProvider;
  final UserSenderModel userSender;

  const NoticeUserDetailScreen({
    required this.userProvider,
    required this.userSender,
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
                userSender: userSender,
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
        child: Column(
          children: [
            userSender.block ? AlertBar('ブロック中') : Container(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(
                    color: kMsgBgColor,
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          '送信者名',
                          style: TextStyle(fontSize: 14),
                        ),
                        Text(
                          userSender.senderUserName,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'SourceHanSansJP-Bold',
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  userSender.block
                      ? CustomButton(
                          type: ButtonSizeType.lg,
                          label: 'ブロックを解除する',
                          labelColor: kBlackColor,
                          backgroundColor: kBlackColor.withOpacity(0.3),
                          onPressed: () => showDialog(
                            context: context,
                            builder: (context) => UnBlockDialog(
                              userProvider: userProvider,
                              userSender: userSender,
                            ),
                          ),
                        )
                      : CustomButton(
                          type: ButtonSizeType.lg,
                          label: 'ブロックする',
                          labelColor: kWhiteColor,
                          backgroundColor: kRedColor,
                          onPressed: () => showDialog(
                            context: context,
                            builder: (context) => BlockDialog(
                              userProvider: userProvider,
                              userSender: userSender,
                            ),
                          ),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DelDialog extends StatelessWidget {
  final UserProvider userProvider;
  final UserSenderModel userSender;

  const DelDialog({
    required this.userProvider,
    required this.userSender,
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
            String? error = await userProvider.removeUserSender(
              userSender: userSender,
            );
            if (error != null) {
              showMessage(context, error, false);
              return;
            }
            Navigator.pop(context);
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}

class BlockDialog extends StatelessWidget {
  final UserProvider userProvider;
  final UserSenderModel userSender;

  const BlockDialog({
    required this.userProvider,
    required this.userSender,
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
            '本当にブロックしますか？',
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
          label: 'ブロックする',
          labelColor: kWhiteColor,
          backgroundColor: kRedColor,
          onPressed: () async {
            String? error = await userProvider.blockUserSender(
              userSender: userSender,
            );
            if (error != null) {
              showMessage(context, error, false);
              return;
            }
            Navigator.pop(context);
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}

class UnBlockDialog extends StatelessWidget {
  final UserProvider userProvider;
  final UserSenderModel userSender;

  const UnBlockDialog({
    required this.userProvider,
    required this.userSender,
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
            '本当にブロックを解除しますか？',
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
          label: 'ブロックを解除する',
          labelColor: kWhiteColor,
          backgroundColor: kRedColor,
          onPressed: () async {
            String? error = await userProvider.unblockUserSender(
              userSender: userSender,
            );
            if (error != null) {
              showMessage(context, error, false);
              return;
            }
            Navigator.pop(context);
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}
