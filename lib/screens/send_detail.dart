import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:simple_alert_app/common/functions.dart';
import 'package:simple_alert_app/common/style.dart';
import 'package:simple_alert_app/models/user_send.dart';
import 'package:simple_alert_app/widgets/alert_bar.dart';
import 'package:simple_alert_app/widgets/choice_list.dart';
import 'package:simple_alert_app/widgets/map_user_sheet.dart';

class SendDetailScreen extends StatefulWidget {
  final UserSendModel userSend;

  const SendDetailScreen({
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
          MapUserSheet(widget.userSend.sendMapUsers),
        ],
      ),
    );
  }
}
