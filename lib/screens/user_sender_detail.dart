import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:restart_app/restart_app.dart';
import 'package:simple_alert_app/common/functions.dart';
import 'package:simple_alert_app/common/style.dart';
import 'package:simple_alert_app/providers/user.dart';

class UserSenderDetailScreen extends StatefulWidget {
  final UserProvider userProvider;

  const UserSenderDetailScreen({
    required this.userProvider,
    super.key,
  });

  @override
  State<UserSenderDetailScreen> createState() => _UserSenderDetailScreenState();
}

class _UserSenderDetailScreenState extends State<UserSenderDetailScreen> {
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
        title: Text(
          '送信者情報',
          style: TextStyle(color: kBlackColor),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              String? error = await widget.userProvider.senderReset();
              if (error != null) {
                if (!mounted) return;
                showMessage(context, error, false);
                return;
              }
              await widget.userProvider.reload();
              Restart.restartApp(
                notificationTitle: 'アプリの再起動',
                notificationBody: 'ログイン情報を再読み込みするため、アプリを再起動します。',
              );
            },
            child: Text(
              '登録を解除',
              style: TextStyle(color: kRedColor),
            ),
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        behavior: HitTestBehavior.opaque,
        child: SafeArea(
          child: Column(
            children: [
              // UserList(
              //   label: '送信者番号',
              //   subtitle: Text(
              //     widget.userProvider.user!.senderNumber,
              //     style: TextStyle(fontSize: 14),
              //   ),
              //   trailing: LinkText(
              //     label: '共有',
              //     onTap: () {},
              //   ),
              // ),
              // UserList(
              //   label: '送信者名',
              //   subtitle: Text(
              //     widget.userProvider.user!.senderName,
              //     style: TextStyle(fontSize: 14),
              //   ),
              //   trailing: const FaIcon(
              //     FontAwesomeIcons.pen,
              //     size: 16,
              //   ),
              //   onTap: () {
              //     Navigator.push(
              //       context,
              //       PageTransition(
              //         type: PageTransitionType.rightToLeft,
              //         child: UserSenderNameScreen(
              //           userProvider: widget.userProvider,
              //         ),
              //       ),
              //     );
              //   },
              // ),
              // UserList(
              //   label: '登録プラン',
              //   subtitle: Text(
              //     'スタンダード',
              //     style: TextStyle(fontSize: 14),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
