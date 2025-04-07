import 'package:floating_navigation_bar/floating_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:simple_alert_app/common/functions.dart';
import 'package:simple_alert_app/common/style.dart';
import 'package:simple_alert_app/providers/in_app_purchase.dart';
import 'package:simple_alert_app/providers/user.dart';
import 'package:simple_alert_app/screens/info.dart';
import 'package:simple_alert_app/screens/notice.dart';
import 'package:simple_alert_app/screens/send.dart';
import 'package:simple_alert_app/screens/setting.dart';
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

  void _init() {
    context.read<InAppPurchaseProvider>().initialize();
    bannerAd.load();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    super.dispose();
    // context.read<InAppPurchaseProvider>().dispose();
    // bannerAd.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final inAppPurchaseProvider = context.read<InAppPurchaseProvider>();
    List<String> titles = ['受信機能', '送信機能'];
    List<Widget> bodies = [
      NoticeScreen(userProvider: userProvider),
      SendScreen(userProvider: userProvider),
    ];
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(titles[currentIndex]),
        actions: [
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.user),
            onPressed: () => showBottomUpScreen(
              context,
              SettingScreen(userProvider: userProvider),
            ),
          ),
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.ellipsisVertical),
            onPressed: () => showBottomUpScreen(
              context,
              InfoScreen(),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          inAppPurchaseProvider.planAdView
              ? SizedBox(
                  width: bannerAd.size.width.toDouble(),
                  height: bannerAd.size.height.toDouble(),
                  child: AdWidget(ad: bannerAd),
                )
              : Container(),
          Expanded(child: bodies[currentIndex]),
        ],
      ),
      extendBody: true,
      bottomNavigationBar: Padding(
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
          items: [
            NavBarItems(
              icon: FontAwesomeIcons.earListen,
              title: '受信機能',
            ),
            NavBarItems(
              icon: FontAwesomeIcons.paperPlane,
              title: '送信機能',
            ),
          ],
          onChanged: (value) {
            currentIndex = value;
            setState(() {});
          },
        ),
      ),
      bottomSheet: CustomBottomSheet(),
    );
  }
}
