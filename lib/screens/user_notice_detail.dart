import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:simple_alert_app/common/functions.dart';
import 'package:simple_alert_app/common/style.dart';
import 'package:simple_alert_app/models/user_notice.dart';
import 'package:simple_alert_app/providers/user.dart';
import 'package:simple_alert_app/services/user_notice.dart';
import 'package:simple_alert_app/widgets/custom_button.dart';

class UserNoticeDetailScreen extends StatefulWidget {
  final UserProvider userProvider;
  final UserNoticeModel userNotice;

  const UserNoticeDetailScreen({
    required this.userProvider,
    required this.userNotice,
    super.key,
  });

  @override
  State<UserNoticeDetailScreen> createState() => _UserNoticeDetailScreenState();
}

class _UserNoticeDetailScreenState extends State<UserNoticeDetailScreen> {
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
    await requestReview();
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
                            Text(widget.userNotice.content),
                          ],
                        ),
                      ),
                      widget.userNotice.isChoice
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 16),
                                Text(
                                  '※この通知は回答を求めています。',
                                  style: TextStyle(color: kRedColor),
                                ),
                                SizedBox(height: 4),
                                Column(
                                  children:
                                      widget.userNotice.choices.map((choice) {
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 4),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: kBlackColor.withOpacity(0.5),
                                          ),
                                        ),
                                        child: RadioListTile(
                                          title: Text(choice),
                                          value: choice,
                                          groupValue: answer,
                                          onChanged: (value) {
                                            if (value == null) return;
                                            setState(() {
                                              answer = value;
                                            });
                                          },
                                          activeColor: kBlueColor,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                                SizedBox(height: 4),
                                CustomButton(
                                  type: ButtonSizeType.lg,
                                  label: '回答を送信',
                                  labelColor: kWhiteColor,
                                  backgroundColor: kBlueColor,
                                  onPressed: () async {
                                    String? error =
                                        await widget.userProvider.answer(
                                      userNotice: widget.userNotice,
                                      answer: answer,
                                    );
                                    if (error != null) {
                                      if (!mounted) return;
                                      showMessage(context, error, false);
                                      return;
                                    }
                                    if (!mounted) return;
                                    Navigator.pop(context);
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
    );
  }
}
