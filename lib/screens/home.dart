import 'package:floating_navigation_bar/floating_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:simple_alert_app/common/functions.dart';
import 'package:simple_alert_app/models/user.dart';
import 'package:simple_alert_app/providers/user.dart';
import 'package:simple_alert_app/screens/send.dart';
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
  List<Widget> screenWidgets = [];
  List<String> headerNames = [];
  List<NavBarItems> navItems = [];

  void _init() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    UserModel? user = userProvider.user;
    screenWidgets = [
      UserNoticeScreen(userProvider: userProvider),
      UserScreen(userProvider: userProvider),
    ];
    headerNames = ['受信履歴', 'マイページ'];
    navItems = [
      NavBarItems(
        icon: FontAwesomeIcons.rectangleList,
        title: '受信履歴',
      ),
      NavBarItems(
        icon: FontAwesomeIcons.user,
        title: 'マイページ',
      ),
    ];
    if (user != null) {
      if (user.isSender) {
        screenWidgets = [
          UserNoticeScreen(userProvider: userProvider),
          SendScreen(userProvider: userProvider),
          UserScreen(userProvider: userProvider),
        ];
        headerNames = ['受信履歴', '送信機能', 'マイページ'];
        navItems = [
          NavBarItems(
            icon: FontAwesomeIcons.rectangleList,
            title: '受信履歴',
          ),
          NavBarItems(
            icon: FontAwesomeIcons.paperPlane,
            title: '送信機能',
          ),
          NavBarItems(
            icon: FontAwesomeIcons.user,
            title: 'マイページ',
          ),
        ];
      }
    }
  }

  @override
  void initState() {
    _init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(headerNames[currentIndex]),
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
        items: navItems,
        onChanged: (value) {
          currentIndex = value;
          setState(() {});
        },
      ),
    );
  }
}
