import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:simple_alert_app/common/style.dart';

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
            Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: kBlackColor.withOpacity(0.5),
                  ),
                ),
              ),
              child: SwitchListTile(
                title: Text('PUSH通知のON/OFF'),
                value: false,
                onChanged: (value) {},
              ),
            ),
            Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: kBlackColor.withOpacity(0.5),
                  ),
                ),
              ),
              child: ListTile(
                title: Text('お問い合わせ'),
                trailing: const FaIcon(
                  FontAwesomeIcons.chevronRight,
                  size: 16,
                ),
                onTap: () {},
              ),
            ),
            Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: kBlackColor.withOpacity(0.5),
                  ),
                ),
              ),
              child: ListTile(
                title: Text('利用規約'),
                trailing: const FaIcon(
                  FontAwesomeIcons.chevronRight,
                  size: 16,
                ),
                onTap: () {},
              ),
            ),
            Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: kBlackColor.withOpacity(0.5),
                  ),
                ),
              ),
              child: ListTile(
                title: Text('プライバシーポリシー'),
                trailing: const FaIcon(
                  FontAwesomeIcons.chevronRight,
                  size: 16,
                ),
                onTap: () {},
              ),
            ),
            Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: kBlackColor.withOpacity(0.5),
                  ),
                ),
              ),
              child: ListTile(
                title: Text('アプリのバージョン'),
                trailing: Text(
                  '1.0.0',
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
