import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:simple_alert_app/common/functions.dart';
import 'package:simple_alert_app/common/style.dart';
import 'package:simple_alert_app/models/user_notice.dart';
import 'package:simple_alert_app/providers/user.dart';
import 'package:simple_alert_app/services/user_notice.dart';
import 'package:simple_alert_app/widgets/alert_bar.dart';
import 'package:simple_alert_app/widgets/choice_radio_list.dart';
import 'package:simple_alert_app/widgets/custom_alert_dialog.dart';
import 'package:simple_alert_app/widgets/custom_button.dart';

class NoticeDetailScreen extends StatefulWidget {
  final UserProvider userProvider;
  final UserNoticeModel userNotice;

  const NoticeDetailScreen({
    required this.userProvider,
    required this.userNotice,
    super.key,
  });

  @override
  State<NoticeDetailScreen> createState() => _NoticeDetailScreenState();
}

class _NoticeDetailScreenState extends State<NoticeDetailScreen> {
  String answer = '';

  void _init() async {
    if (!widget.userNotice.read) {
      UserNoticeService().update({
        'id': widget.userNotice.id,
        'userId': widget.userNotice.userId,
        'read': true,
      });
    }
    //レビューの促し
    //await requestReview();
  }

  @override
  void initState() {
    answer = widget.userNotice.answer;
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
        child: Column(
          children: [
            widget.userNotice.isChoice
                ? AlertBar('この通知は回答が求められています')
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
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            Container(
                              color: kMsgBgColor,
                              padding: EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(
                                    widget.userNotice.title,
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'SourceHanSansJP-Bold',
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    widget.userNotice.content,
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                            ),
                            widget.userNotice.isChoice
                                ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(height: 16),
                                      Text('選択してください'),
                                      Column(
                                        children: widget.userNotice.choices
                                            .map((choice) {
                                          return ChoiceRadioList(
                                            value: choice,
                                            groupValue: answer,
                                            onChanged:
                                                widget.userNotice.answer == ''
                                                    ? (value) {
                                                        if (value == null)
                                                          return;
                                                        setState(() {
                                                          answer = value;
                                                        });
                                                      }
                                                    : null,
                                          );
                                        }).toList(),
                                      ),
                                      SizedBox(height: 8),
                                      answer != ''
                                          ? CustomButton(
                                              type: ButtonSizeType.lg,
                                              label: '回答を送信',
                                              labelColor: kWhiteColor,
                                              backgroundColor: kBlueColor,
                                              onPressed: () => showDialog(
                                                context: context,
                                                builder: (context) =>
                                                    AnswerDialog(
                                                  userProvider:
                                                      widget.userProvider,
                                                  userNotice: widget.userNotice,
                                                  answer: answer,
                                                ),
                                              ),
                                              disabled:
                                                  widget.userNotice.answer !=
                                                      '',
                                            )
                                          : Container(),
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
      ),
    );
  }
}

class AnswerDialog extends StatefulWidget {
  final UserProvider userProvider;
  final UserNoticeModel userNotice;
  final String answer;

  const AnswerDialog({
    required this.userProvider,
    required this.userNotice,
    required this.answer,
    super.key,
  });

  @override
  State<AnswerDialog> createState() => _AnswerDialogState();
}

class _AnswerDialogState extends State<AnswerDialog> {
  @override
  Widget build(BuildContext context) {
    return CustomAlertDialog(
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 8),
          Text('本当に送信しますか？'),
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
          label: '送信する',
          labelColor: kWhiteColor,
          backgroundColor: kBlueColor,
          onPressed: () async {
            String? error = await widget.userProvider.answer(
              userNotice: widget.userNotice,
              answer: widget.answer,
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
