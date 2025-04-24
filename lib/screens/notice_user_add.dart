import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:simple_alert_app/common/functions.dart';
import 'package:simple_alert_app/common/style.dart';
import 'package:simple_alert_app/models/user.dart';
import 'package:simple_alert_app/models/user_sender.dart';
import 'package:simple_alert_app/providers/user.dart';
import 'package:simple_alert_app/services/user.dart';
import 'package:simple_alert_app/services/user_sender.dart';
import 'package:simple_alert_app/widgets/alert_bar.dart';
import 'package:simple_alert_app/widgets/custom_alert_dialog.dart';
import 'package:simple_alert_app/widgets/custom_button.dart';
import 'package:simple_alert_app/widgets/custom_text_form_field.dart';

class NoticeUserAddScreen extends StatefulWidget {
  final UserProvider userProvider;

  const NoticeUserAddScreen({
    required this.userProvider,
    super.key,
  });

  @override
  State<NoticeUserAddScreen> createState() => _NoticeUserAddScreenState();
}

class _NoticeUserAddScreenState extends State<NoticeUserAddScreen> {
  TextEditingController senderIdController = TextEditingController();

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
        title: const Text(
          '受信先を追加',
          style: TextStyle(color: kBlackColor),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        behavior: HitTestBehavior.opaque,
        child: SafeArea(
          child: Column(
            children: [
              AlertBar('送信者IDを入力してください'),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    CustomTextFormField(
                      controller: senderIdController,
                      textInputType: TextInputType.text,
                      maxLines: 1,
                      label: '送信者ID',
                      color: kBlackColor,
                      prefix: Icons.numbers,
                      fillColor: kBlackColor.withOpacity(0.1),
                    ),
                    SizedBox(height: 16),
                    CustomButton(
                      type: ButtonSizeType.lg,
                      label: '上記IDで検索',
                      labelColor: kWhiteColor,
                      backgroundColor: kBlueColor,
                      onPressed: () async {
                        if (senderIdController.text == '') {
                          if (!mounted) return;
                          showMessage(context, '送信者IDを入力してください', false);
                          return;
                        }
                        UserModel? resultUser = await UserService().selectData(
                          senderId: senderIdController.text,
                        );
                        if (resultUser == null || resultUser.sender == false) {
                          if (!mounted) return;
                          showMessage(context, '送信者が見つかりませんでした', false);
                          return;
                        }
                        if (!mounted) return;
                        showDialog(
                          barrierDismissible: false,
                          context: context,
                          builder: (context) => ResultUserDialog(
                            userProvider: widget.userProvider,
                            resultUser: resultUser,
                          ),
                        );
                        return;
                      },
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

class ResultUserDialog extends StatefulWidget {
  final UserProvider userProvider;
  final UserModel resultUser;

  const ResultUserDialog({
    required this.userProvider,
    required this.resultUser,
    super.key,
  });

  @override
  State<ResultUserDialog> createState() => _ResultUserDialogState();
}

class _ResultUserDialogState extends State<ResultUserDialog> {
  bool disabled = false;

  void _init() async {
    UserSenderModel? userSender = await UserSenderService().selectData(
      userId: widget.userProvider.user!.id,
      senderUserId: widget.resultUser.id,
    );
    if (userSender != null) {
      disabled = true;
    }
    setState(() {});
  }

  @override
  void initState() {
    _init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CustomAlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 8),
          Text('以下の送信者が見つかりました！'),
          Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: kBlackColor.withOpacity(0.5)),
              ),
            ),
            child: ListTile(title: Text(widget.resultUser.senderName)),
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
          label: '追加する',
          labelColor: kWhiteColor,
          backgroundColor: kBlueColor,
          onPressed: () async {
            String? error = await widget.userProvider.addSenderUser(
              senderUser: widget.resultUser,
            );
            if (error != null) {
              showMessage(context, error, false);
              return;
            }
            if (!mounted) return;
            showMessage(context, '受信先を追加しました', true);
            Navigator.pop(context);
            Navigator.pop(context);
          },
          disabled: disabled,
        ),
      ],
    );
  }
}
