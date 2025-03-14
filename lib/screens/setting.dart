import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:simple_alert_app/common/style.dart';
import 'package:simple_alert_app/widgets/custom_list.dart';
import 'package:simple_alert_app/widgets/custom_switch_list.dart';

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
            CustomSwitchList(
              titleLabel: 'PUSH通知のON/OFF',
              value: false,
              onChanged: (value) {},
            ),
            CustomList(
              titleLabel: '利用規約',
              trailing: const FaIcon(
                FontAwesomeIcons.chevronRight,
                size: 16,
              ),
              onTap: () {},
            ),
            CustomList(
              titleLabel: 'プライバシーポリシー',
              trailing: const FaIcon(
                FontAwesomeIcons.chevronRight,
                size: 16,
              ),
              onTap: () {},
            ),
            CustomList(
              titleLabel: 'アプリのバージョン',
              trailing: Text(
                '1.0.0',
                style: TextStyle(fontSize: 14),
              ),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}
