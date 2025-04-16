import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:simple_alert_app/common/functions.dart';
import 'package:simple_alert_app/common/style.dart';
import 'package:simple_alert_app/models/map_user.dart';
import 'package:simple_alert_app/models/user.dart';
import 'package:simple_alert_app/models/user_send.dart';
import 'package:simple_alert_app/providers/user.dart';
import 'package:simple_alert_app/services/user_send.dart';
import 'package:simple_alert_app/widgets/alert_bar.dart';
import 'package:simple_alert_app/widgets/custom_alert_dialog.dart';
import 'package:simple_alert_app/widgets/custom_button.dart';
import 'package:simple_alert_app/widgets/custom_check_list.dart';

class SendSelectScreen extends StatefulWidget {
  final UserProvider userProvider;
  final UserSendModel? userSend;
  final String title;
  final String content;
  final bool isChoice;
  final List<String> choices;

  const SendSelectScreen({
    required this.userProvider,
    this.userSend,
    required this.title,
    required this.content,
    required this.isChoice,
    required this.choices,
    super.key,
  });

  @override
  State<SendSelectScreen> createState() => _SendSelectScreenState();
}

class _SendSelectScreenState extends State<SendSelectScreen> {
  List<MapUserModel> sendMapUsers = [];
  List<MapUserModel> selectedSendMapUsers = [];
  int monthSendCount = 0;

  void _init() async {
    monthSendCount = await UserSendService().selectMonthSendCount(
      userId: widget.userProvider.user!.id,
    );
    setState(() {});
  }

  @override
  void initState() {
    UserModel user = widget.userProvider.user!;
    sendMapUsers = user.sendMapUsers;
    super.initState();
    _init();
  }

  @override
  Widget build(BuildContext context) {
    int selectedLimit = 0;
    // if (inAppPurchaseProvider.planMonthLimit > monthSendCount) {
    //   selectedLimit = inAppPurchaseProvider.planMonthLimit - monthSendCount;
    // }
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
              if (selectedSendMapUsers.isEmpty) {
                selectedSendMapUsers = sendMapUsers;
              } else {
                selectedSendMapUsers = [];
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
              child: sendMapUsers.isNotEmpty
                  ? ListView.builder(
                      itemCount: sendMapUsers.length,
                      itemBuilder: (context, index) {
                        MapUserModel mapUser = sendMapUsers[index];
                        bool value = selectedSendMapUsers.contains(mapUser);
                        return CustomCheckList(
                          label: mapUser.name,
                          value: value,
                          onChanged: (value) {
                            if (!selectedSendMapUsers.contains(mapUser)) {
                              selectedSendMapUsers.add(mapUser);
                            } else {
                              selectedSendMapUsers.remove(mapUser);
                            }
                            setState(() {});
                          },
                          activeColor: kBlueColor,
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
      floatingActionButton: selectedSendMapUsers.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () async {
                if (selectedSendMapUsers.length > selectedLimit) {
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
                    selectedSendMapUsers: selectedSendMapUsers,
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
  }
}

class SendDialog extends StatefulWidget {
  final UserProvider userProvider;
  final UserSendModel? userSend;
  final String title;
  final String content;
  final bool isChoice;
  final List<String> choices;
  final List<MapUserModel> selectedSendMapUsers;

  const SendDialog({
    required this.userProvider,
    required this.userSend,
    required this.title,
    required this.content,
    required this.isChoice,
    required this.choices,
    required this.selectedSendMapUsers,
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
              selectedSendMapUsers: widget.selectedSendMapUsers,
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
