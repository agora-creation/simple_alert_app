import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:simple_alert_app/common/functions.dart';
import 'package:simple_alert_app/common/style.dart';
import 'package:simple_alert_app/models/user.dart';
import 'package:simple_alert_app/providers/user.dart';
import 'package:simple_alert_app/services/user.dart';
import 'package:simple_alert_app/widgets/custom_alert_dialog.dart';
import 'package:simple_alert_app/widgets/custom_button.dart';

class NoticeSettingUsersAddScreen extends StatefulWidget {
  final UserProvider userProvider;
  final Function(UserModel) reload;

  const NoticeSettingUsersAddScreen({
    required this.userProvider,
    required this.reload,
    super.key,
  });

  @override
  State<NoticeSettingUsersAddScreen> createState() =>
      _NoticeSettingUsersAddScreenState();
}

class _NoticeSettingUsersAddScreenState
    extends State<NoticeSettingUsersAddScreen> {
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
      body: MobileScanner(
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
                  reload: widget.reload,
                  senderUser: senderUser,
                ),
              );
            }
          }
        },
      ),
    );
  }
}

class SenderUserDialog extends StatelessWidget {
  final UserProvider userProvider;
  final Function(UserModel) reload;
  final UserModel senderUser;

  const SenderUserDialog({
    required this.userProvider,
    required this.reload,
    required this.senderUser,
    super.key,
  });

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
            child: ListTile(title: Text(senderUser.senderName)),
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
            String? error = await userProvider.addNoticeMapUsers(
              senderUser: senderUser,
            );
            if (error != null) {
              showMessage(context, error, false);
              return;
            }
            await userProvider.reload();
            reload(userProvider.user!);
            Navigator.pop(context);
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}
