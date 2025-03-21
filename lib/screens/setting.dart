import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:simple_alert_app/common/functions.dart';
import 'package:simple_alert_app/common/style.dart';
import 'package:simple_alert_app/widgets/setting_list.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kWhiteColor,
      appBar: AppBar(
        backgroundColor: kWhiteColor,
        automaticallyImplyLeading: false,
        title: const Text(
          '設定',
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
            SettingList(
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
            SettingList(
              label: 'アプリのバージョン',
              trailing: FutureBuilder<String>(
                future: getVersionInfo(),
                builder: (context, snapshot) {
                  return Text(
                    snapshot.data ?? '',
                    style: TextStyle(fontSize: 14),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
