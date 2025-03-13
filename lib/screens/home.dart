import 'package:floating_navigation_bar/floating_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:simple_alert_app/common/functions.dart';
import 'package:simple_alert_app/common/style.dart';
import 'package:simple_alert_app/screens/setting.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;

  List<Widget> screens = [
    Center(
      child: Text('受信履歴'),
    ),
    Center(
      child: Text('送信履歴'),
    ),
    Center(
      child: Text('リマインダー'),
    ),
    Center(
      child: Text('名無し'),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('受信履歴'),
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
      body: screens[currentIndex],
      extendBody: true,
      bottomNavigationBar: Container(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: FloatingNavigationBar(
          backgroundColor: kWhiteColor,
          barHeight: 80,
          barWidth: MediaQuery.of(context).size.width - 40,
          iconColor: kBlackColor,
          textStyle: TextStyle(
            color: kBlackColor,
            fontSize: 14,
          ),
          iconSize: 18,
          indicatorColor: kRedColor,
          indicatorHeight: 4,
          indicatorWidth: 20,
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
      ),
    );
  }
}
