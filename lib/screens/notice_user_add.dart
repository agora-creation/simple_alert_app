import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
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
  MobileScannerController controller = MobileScannerController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
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
        title: const Text(
          '受信先を追加',
          style: TextStyle(color: kBlackColor),
        ),
      ),
      body: Column(
        children: [
          AlertBar('専用のQRコードをスキャンしてください'),
          Expanded(
            child: MobileScanner(
              controller: controller,
              onDetect: (capture) async {
                final barcode = capture.barcodes.first;
                final code = barcode.rawValue;
                if (code != null) {
                  String id = code.replaceAll('AGORA-', '');
                  UserModel? senderUser = await UserService().selectDataQR(id);
                  if (senderUser != null) {
                    showDialog(
                      barrierDismissible: false,
                      context: context,
                      builder: (context) => SenderUserDialog(
                        userProvider: widget.userProvider,
                        senderUser: senderUser,
                        controller: controller,
                      ),
                    );
                  }
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class SenderUserDialog extends StatefulWidget {
  final UserProvider userProvider;
  final UserModel senderUser;
  final MobileScannerController controller;

  const SenderUserDialog({
    required this.userProvider,
    required this.senderUser,
    required this.controller,
    super.key,
  });

  @override
  State<SenderUserDialog> createState() => _SenderUserDialogState();
}

class _SenderUserDialogState extends State<SenderUserDialog> {
  bool disabled = false;

  void _init() async {
    UserSenderModel? userSender = await UserSenderService().selectData(
      userId: widget.userProvider.user!.id,
      senderUserId: widget.senderUser.id,
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
            child: ListTile(title: Text(widget.senderUser.senderName)),
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
              senderUser: widget.senderUser,
            );
            if (error != null) {
              showMessage(context, error, false);
              return;
            }
            widget.controller.dispose();
            Navigator.pop(context);
            Navigator.pop(context);
          },
          disabled: disabled,
        ),
      ],
    );
  }
}
