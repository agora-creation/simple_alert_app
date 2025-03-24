import 'package:floating_navigation_bar/floating_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:simple_alert_app/common/functions.dart';
import 'package:simple_alert_app/common/style.dart';
import 'package:simple_alert_app/models/user.dart';
import 'package:simple_alert_app/providers/user.dart';
import 'package:simple_alert_app/screens/send.dart';
import 'package:simple_alert_app/screens/setting.dart';
import 'package:simple_alert_app/screens/user.dart';
import 'package:simple_alert_app/screens/user_notice.dart';
import 'package:simple_alert_app/services/ad.dart';
import 'package:simple_alert_app/widgets/custom_bottom_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  BannerAd bannerAd = AdService.createBannerAd();
  int currentIndex = 0;

  @override
  void initState() {
    currentIndex = 0;
    super.initState();
    bannerAd.load();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: HomeAppbarTitle(
          user: userProvider.user,
          currentIndex: currentIndex,
        ),
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
      body: HomeBody(
        userProvider: userProvider,
        currentIndex: currentIndex,
        bannerAd: bannerAd,
      ),
      extendBody: true,
      bottomNavigationBar: HomeBottomNavigationBar(
        user: userProvider.user,
        onChanged: (value) {
          currentIndex = value;
          setState(() {});
        },
      ),
      bottomSheet: CustomBottomSheet(),
    );
  }
}

class HomeAppbarTitle extends StatelessWidget {
  final UserModel? user;
  final int currentIndex;

  const HomeAppbarTitle({
    required this.user,
    required this.currentIndex,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    List<String> titles = ['受信履歴', 'マイページ'];
    if (user != null && user!.isSender) {
      titles = ['受信履歴', '送信機能', 'マイページ'];
    }
    return Text(titles[currentIndex]);
  }
}

class HomeBody extends StatelessWidget {
  final UserProvider userProvider;
  final int currentIndex;
  final BannerAd bannerAd;

  const HomeBody({
    required this.userProvider,
    required this.currentIndex,
    required this.bannerAd,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    List<Widget> bodies = [
      UserNoticeScreen(userProvider: userProvider),
      UserScreen(userProvider: userProvider),
    ];
    UserModel? user = userProvider.user;
    if (user != null && user.isSender) {
      bodies = [
        UserNoticeScreen(userProvider: userProvider),
        SendScreen(userProvider: userProvider),
        UserScreen(userProvider: userProvider),
      ];
    }
    return Column(
      children: [
        SizedBox(
          width: bannerAd.size.width.toDouble(),
          height: bannerAd.size.height.toDouble(),
          child: AdWidget(ad: bannerAd),
        ),
        Expanded(child: bodies[currentIndex]),
      ],
    );
  }
}

class HomeBottomNavigationBar extends StatelessWidget {
  final UserModel? user;
  final Function(int) onChanged;

  const HomeBottomNavigationBar({
    required this.user,
    required this.onChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    List<NavBarItems> items = [
      NavBarItems(
        icon: FontAwesomeIcons.rectangleList,
        title: '受信履歴',
      ),
      NavBarItems(
        icon: FontAwesomeIcons.user,
        title: 'マイページ',
      ),
    ];
    if (user != null && user!.isSender) {
      items = [
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
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
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
        items: items,
        onChanged: onChanged,
      ),
    );
  }
}
