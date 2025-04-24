import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:simple_alert_app/common/functions.dart';
import 'package:simple_alert_app/common/style.dart';
import 'package:simple_alert_app/models/user_send.dart';
import 'package:simple_alert_app/providers/user.dart';
import 'package:simple_alert_app/widgets/alert_bar.dart';
import 'package:simple_alert_app/widgets/choice_list.dart';
import 'package:simple_alert_app/widgets/custom_alert_dialog.dart';
import 'package:simple_alert_app/widgets/custom_button.dart';
import 'package:simple_alert_app/widgets/link_text.dart';
import 'package:simple_alert_app/widgets/send_user_sheet.dart';
import 'package:url_launcher/url_launcher.dart';

class SendDetailScreen extends StatefulWidget {
  final UserProvider userProvider;
  final UserSendModel userSend;

  const SendDetailScreen({
    required this.userProvider,
    required this.userSend,
    super.key,
  });

  @override
  State<SendDetailScreen> createState() => _SendDetailScreenState();
}

class _SendDetailScreenState extends State<SendDetailScreen> {
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
                userProvider: widget.userProvider,
                userSend: widget.userSend,
              ),
            ),
            child: Text(
              '削除',
              style: TextStyle(color: kRedColor),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              widget.userSend.isChoice
                  ? AlertBar('この通知は回答設定されています')
                  : Container(),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.centerRight,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '送信日時: ${dateText('yyyy/MM/dd HH:mm', widget.userSend.createdAt)}',
                              style: TextStyle(
                                color: kBlackColor.withOpacity(0.8),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                color: kMsgBgColor,
                                padding: EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Text(
                                      widget.userSend.title,
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'SourceHanSansJP-Bold',
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      widget.userSend.content,
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ],
                                ),
                              ),
                              widget.userSend.isChoice
                                  ? Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(height: 16),
                                        Text('選択肢'),
                                        Column(
                                          children: widget.userSend.choices
                                              .map((choice) {
                                            return ChoiceList(choice);
                                          }).toList(),
                                        ),
                                      ],
                                    )
                                  : Container(),
                              const SizedBox(height: 16),
                              widget.userSend.fileName != ''
                                  ? Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '添付ファイル',
                                          style: TextStyle(fontSize: 14),
                                        ),
                                        LinkText(
                                          label: widget.userSend.fileName,
                                          onTap: () async {
                                            if (!await launchUrl(Uri.parse(
                                              widget.userSend.fileName,
                                            ))) {
                                              throw Exception(
                                                  'Could not launch');
                                            }
                                          },
                                        ),
                                      ],
                                    )
                                  : Container(),
                              SizedBox(height: 100),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SendUserSheet(widget.userSend.sendUsers),
        ],
      ),
    );
  }
}

class DelDialog extends StatefulWidget {
  final UserProvider userProvider;
  final UserSendModel userSend;

  const DelDialog({
    required this.userProvider,
    required this.userSend,
    super.key,
  });

  @override
  State<DelDialog> createState() => _DelDialogState();
}

class _DelDialogState extends State<DelDialog> {
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
            String? error = await widget.userProvider.deleteSend(
              userSend: widget.userSend,
            );
            if (error != null) {
              if (!mounted) return;
              showMessage(context, error, false);
              return;
            }
            if (!mounted) return;
            Navigator.pop(context);
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}
