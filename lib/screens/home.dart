import 'package:floating_navigation_bar/floating_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:simple_alert_app/common/functions.dart';
import 'package:simple_alert_app/screens/company_notice.dart';
import 'package:simple_alert_app/screens/reminder.dart';
import 'package:simple_alert_app/screens/setting.dart';
import 'package:simple_alert_app/screens/user.dart';
import 'package:simple_alert_app/screens/user_notice.dart';
import 'package:simple_alert_app/widgets/custom_navigation_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;
  List<Widget> screenWidgets = [
    UserNoticeScreen(),
    CompanyNoticeScreen(),
    ReminderScreen(),
    UserScreen(),
  ];
  List<String> screenNames = ['受信履歴', '送信状況', 'リマインダー', '名無し'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(screenNames[currentIndex]),
        actions: [
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.ellipsisVertical),
            onPressed: () => showBottomUpScreen(
              context,
              SettingScreen(),
            ),
          ),
        ],
      ),
      body: screenWidgets[currentIndex],
      extendBody: true,
      bottomNavigationBar: CustomNavigationBar(
        items: [
          NavBarItems(
            icon: FontAwesomeIcons.rectangleList,
            title: '受信履歴',
          ),
          NavBarItems(
            icon: FontAwesomeIcons.squareCaretDown,
            title: '送信状況',
          ),
          NavBarItems(
            icon: FontAwesomeIcons.paperPlane,
            title: 'リマインダー',
          ),
          NavBarItems(
            icon: FontAwesomeIcons.user,
            title: '名無し',
          ),
        ],
        onChanged: (value) {
          currentIndex = value;
          setState(() {});
        },
      ),
    );
  }
}
