import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:page_transition/page_transition.dart';
import 'package:simple_alert_app/common/functions.dart';
import 'package:simple_alert_app/common/style.dart';
import 'package:simple_alert_app/models/user.dart';
import 'package:simple_alert_app/providers/user.dart';
import 'package:simple_alert_app/screens/info_name.dart';
import 'package:simple_alert_app/screens/login.dart';
import 'package:simple_alert_app/widgets/custom_alert_dialog.dart';
import 'package:simple_alert_app/widgets/custom_button.dart';
import 'package:simple_alert_app/widgets/info_list.dart';
import 'package:simple_alert_app/widgets/link_text.dart';
import 'package:url_launcher/url_launcher.dart';

class InfoScreen extends StatelessWidget {
  final UserProvider userProvider;

  const InfoScreen({
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
            InfoList(
              label: '名前',
              trailing: Text(
                user?.name ?? '',
                style: TextStyle(
                  color: kBlackColor,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'SourceHanSansJP-Bold',
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  PageTransition(
                    type: PageTransitionType.rightToLeft,
                    child: InfoNameScreen(
                      userProvider: userProvider,
                    ),
                  ),
                );
              },
            ),
            InfoList(
              label: '利用規約',
              trailing: const FaIcon(
                FontAwesomeIcons.chevronRight,
                size: 16,
              ),
              onTap: () async {
                if (!await launchUrl(Uri.parse(
                  'https://docs.google.com/document/d/18yzTySjHTdCE_VHS6NjAeP8OfTpfqyh5VZjaqBgdP78/edit?usp=sharing',
                ))) {
                  throw Exception('Could not launch');
                }
              },
            ),
            InfoList(
              label: 'プライバシーポリシー',
              trailing: const FaIcon(
                FontAwesomeIcons.chevronRight,
                size: 16,
              ),
              onTap: () async {
                if (!await launchUrl(Uri.parse(
                  'https://docs.google.com/document/d/1HIbeGeI1HEl1JnVBTiFjrJk0JZeUWSehahu4WfApWR4/edit?usp=sharing',
                ))) {
                  throw Exception('Could not launch');
                }
              },
            ),
            InfoList(
              label: 'アプリについての意見・要望',
              trailing: const FaIcon(
                FontAwesomeIcons.chevronRight,
                size: 16,
              ),
              onTap: () async {
                if (!await launchUrl(Uri.parse(
                  'https://docs.google.com/forms/d/e/1FAIpQLSdWK2o3g03yquFPKnv-eBZy78_tShlYFZYMe_WAvgON7b3YUg/viewform?usp=sharing',
                ))) {
                  throw Exception('Could not launch');
                }
              },
            ),
            InfoList(
              label: 'アプリのバージョン',
              trailing: FutureBuilder<String>(
                future: getVersionInfo(),
                builder: (context, snapshot) {
                  return Text(
                    snapshot.data ?? '',
                    style: TextStyle(
                      color: kBlackColor,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'SourceHanSansJP-Bold',
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 24),
            Center(
              child: LinkText(
                label: 'ログアウト',
                color: kRedColor,
                onTap: () => showDialog(
                  context: context,
                  builder: (context) => LogoutDialog(
                    userProvider: userProvider,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LogoutDialog extends StatelessWidget {
  final UserProvider userProvider;

  const LogoutDialog({
    required this.userProvider,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return CustomAlertDialog(
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 8),
          Text(
            '本当にログアウトしますか？',
            style: TextStyle(color: kRedColor),
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
          label: 'ログアウト',
          labelColor: kWhiteColor,
          backgroundColor: kRedColor,
          onPressed: () async {
            await userProvider.logout();
            Navigator.pushReplacement(
              context,
              PageTransition(
                type: PageTransitionType.bottomToTop,
                child: LoginScreen(),
              ),
            );
          },
        ),
      ],
    );
  }
}
