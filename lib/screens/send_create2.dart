import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:simple_alert_app/common/functions.dart';
import 'package:simple_alert_app/common/style.dart';
import 'package:simple_alert_app/models/send_user.dart';
import 'package:simple_alert_app/models/user.dart';
import 'package:simple_alert_app/models/user_noticer.dart';
import 'package:simple_alert_app/models/user_send.dart';
import 'package:simple_alert_app/providers/in_app_purchase.dart';
import 'package:simple_alert_app/providers/user.dart';
import 'package:simple_alert_app/services/user_noticer.dart';
import 'package:simple_alert_app/services/user_send.dart';
import 'package:simple_alert_app/widgets/alert_bar.dart';
import 'package:simple_alert_app/widgets/custom_alert_dialog.dart';
import 'package:simple_alert_app/widgets/custom_button.dart';
import 'package:simple_alert_app/widgets/custom_check_list.dart';

class SendCreate2Screen extends StatefulWidget {
  final UserProvider userProvider;
  final UserSendModel? userSend;
  final String title;
  final String content;
  final bool isChoice;
  final List<String> choices;

  const SendCreate2Screen({
    required this.userProvider,
    this.userSend,
    required this.title,
    required this.content,
    required this.isChoice,
    required this.choices,
    super.key,
  });

  @override
  State<SendCreate2Screen> createState() => _SendCreate2ScreenState();
}

class _SendCreate2ScreenState extends State<SendCreate2Screen> {
  int monthSendCount = 0;
  int monthSendLimit = 0;
  List<SendUserModel> selectedSendUsers = [];

  void _init() async {
    monthSendCount = await UserSendService().selectMonthSendCount(
      userId: widget.userProvider.user!.id,
    );
    monthSendLimit = await getMonthSendLimit();
    setState(() {});
  }

  @override
  void initState() {
    _init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    UserModel? user = widget.userProvider.user;
    int selectedLimit = 0;
    if (monthSendLimit > monthSendCount) {
      selectedLimit = monthSendLimit - monthSendCount;
    }
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: UserNoticerService().streamList(userId: user!.id),
      builder: (context, snapshot) {
        List<UserNoticerModel> userNoticers = [];
        if (snapshot.hasData) {
          userNoticers = UserNoticerService().generateList(
            data: snapshot.data,
          );
        }
        return Scaffold(
          backgroundColor: kWhiteColor,
          appBar: AppBar(
            backgroundColor: kWhiteColor,
            leading: IconButton(
              icon: const FaIcon(FontAwesomeIcons.chevronLeft),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              '送信先の選択',
              style: TextStyle(color: kBlackColor),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  if (selectedSendUsers.isEmpty) {
                    selectedSendUsers.clear();
                    if (userNoticers.isNotEmpty) {
                      for (final userNoticer in userNoticers) {
                        SendUserModel sendUser = SendUserModel.fromMap({
                          'id': userNoticer.noticerUserId,
                          'name': userNoticer.noticerUserName,
                          'answer': '',
                        });
                        selectedSendUsers.add(sendUser);
                      }
                    }
                  } else {
                    selectedSendUsers.clear();
                  }
                  setState(() {});
                },
                child: Text(
                  '全選択',
                  style: TextStyle(color: kBlueColor),
                ),
              ),
            ],
          ),
          body: SafeArea(
            child: Column(
              children: [
                AlertBar('あと$selectedLimit件まで送信可'),
                Expanded(
                  child: userNoticers.isNotEmpty
                      ? ListView.builder(
                          itemCount: userNoticers.length,
                          itemBuilder: (context, index) {
                            UserNoticerModel userNoticer = userNoticers[index];
                            bool contain = false;
                            if (selectedSendUsers.isNotEmpty) {
                              for (final sendUser in selectedSendUsers) {
                                if (sendUser.id == userNoticer.noticerUserId) {
                                  contain = true;
                                }
                              }
                            }
                            return CustomCheckList(
                              label: userNoticer.noticerUserName,
                              value: contain,
                              onChanged: (value) {
                                if (contain) {
                                  selectedSendUsers.removeWhere(
                                    (e) => e.id == userNoticer.noticerUserId,
                                  );
                                } else {
                                  selectedSendUsers.add(SendUserModel.fromMap({
                                    'id': userNoticer.noticerUserId,
                                    'name': userNoticer.noticerUserName,
                                    'answer': '',
                                  }));
                                }
                                setState(() {});
                              },
                            );
                          },
                        )
                      : Center(
                          child: Text(
                            '受信者はいません',
                            style: TextStyle(
                              color: kBlackColor.withOpacity(0.5),
                              fontSize: 20,
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
          floatingActionButton: selectedSendUsers.isNotEmpty
              ? FloatingActionButton.extended(
                  onPressed: () async {
                    if (selectedSendUsers.length > selectedLimit) {
                      if (!mounted) return;
                      showMessage(context, '送信制限により送信できません', false);
                      return;
                    }
                    showDialog(
                      context: context,
                      builder: (context) => SendDialog(
                        userProvider: widget.userProvider,
                        userSend: widget.userSend,
                        title: widget.title,
                        content: widget.content,
                        isChoice: widget.isChoice,
                        choices: widget.choices,
                        selectedSendUsers: selectedSendUsers,
                      ),
                    );
                  },
                  icon: const FaIcon(
                    FontAwesomeIcons.paperPlane,
                    size: 18,
                    color: kWhiteColor,
                  ),
                  label: Text(
                    '送信する',
                    style: TextStyle(color: kWhiteColor),
                  ),
                )
              : null,
        );
      },
    );
  }
}

class SendDialog extends StatefulWidget {
  final UserProvider userProvider;
  final UserSendModel? userSend;
  final String title;
  final String content;
  final bool isChoice;
  final List<String> choices;
  final List<SendUserModel> selectedSendUsers;

  const SendDialog({
    required this.userProvider,
    required this.userSend,
    required this.title,
    required this.content,
    required this.isChoice,
    required this.choices,
    required this.selectedSendUsers,
    super.key,
  });

  @override
  State<SendDialog> createState() => _SendDialogState();
}

class _SendDialogState extends State<SendDialog> {
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
            String? error = await widget.userProvider.send(
              userSend: widget.userSend,
              title: widget.title,
              content: widget.content,
              isChoice: widget.isChoice,
              choices: widget.choices,
              selectedSendUsers: widget.selectedSendUsers,
            );
            if (error != null) {
              if (!mounted) return;
              showMessage(context, error, false);
              return;
            }
            //レビューの促し
            //await requestReview();
            if (!mounted) return;
            Navigator.pop(context);
            Navigator.pop(context);
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}
