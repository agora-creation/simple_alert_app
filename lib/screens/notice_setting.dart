import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:page_transition/page_transition.dart';
import 'package:simple_alert_app/common/style.dart';
import 'package:simple_alert_app/models/user.dart';
import 'package:simple_alert_app/providers/user.dart';
import 'package:simple_alert_app/screens/notice_setting_name.dart';
import 'package:simple_alert_app/screens/notice_setting_users.dart';
import 'package:simple_alert_app/widgets/setting_list.dart';

class NoticeSettingScreen extends StatelessWidget {
  final UserProvider userProvider;

  const NoticeSettingScreen({
    required this.userProvider,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    UserModel? user = userProvider.user;
    return Scaffold(
      backgroundColor: kWhiteColor,
      appBar: AppBar(
        backgroundColor: kWhiteColor,
        automaticallyImplyLeading: false,
        title: const Text(
          '受信設定',
          style: TextStyle(color: kBlackColor),
        ),
        actions: [
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.xmark),
            onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            SettingList(
              label: '名前',
              subtitle: Text(
                user?.name ?? '',
                style: TextStyle(fontSize: 14),
              ),
              trailing: const FaIcon(
                FontAwesomeIcons.pen,
                size: 16,
              ),
              onTap: () {
                Navigator.push(
                  context,
                  PageTransition(
                    type: PageTransitionType.rightToLeft,
                    child: NoticeSettingNameScreen(
                      userProvider: userProvider,
                    ),
                  ),
                );
              },
            ),
            SettingList(
              label: '受信先一覧 (${user?.noticeMapUsers.length})',
              trailing: const FaIcon(
                FontAwesomeIcons.chevronRight,
                size: 16,
              ),
              onTap: () {
                Navigator.push(
                  context,
                  PageTransition(
                    type: PageTransitionType.rightToLeft,
                    child: NoticeSettingUsersScreen(
                      userProvider: userProvider,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
