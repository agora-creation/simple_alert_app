import 'package:floating_navigation_bar/floating_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:simple_alert_app/common/functions.dart';
import 'package:simple_alert_app/common/style.dart';
import 'package:simple_alert_app/providers/in_app_purchase.dart';
import 'package:simple_alert_app/providers/user.dart';
import 'package:simple_alert_app/screens/send.dart';
import 'package:simple_alert_app/screens/setting.dart';
import 'package:simple_alert_app/screens/user.dart';
import 'package:simple_alert_app/screens/user_notice.dart';
import 'package:simple_alert_app/services/ad.dart';
import 'package:simple_alert_app/widgets/custom_bottom_sheet.dart';

class HomeScreen extends StatefulWidget {
  final int currentIndex;

  const HomeScreen({
    this.currentIndex = 0,
    super.key,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  BannerAd bannerAd = AdService.createBannerAd();
  int currentIndex = 0;

  void _init() {
    currentIndex = widget.currentIndex;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    bannerAd.load();
    context.read<InAppPurchaseProvider>().initialize();
    _init();
  }

  @override
  void dispose() {
    context.read<InAppPurchaseProvider>().dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final inAppPurchaseProvider = context.read<InAppPurchaseProvider>();
    List<String> titles = ['受信履歴', '送信履歴', 'マイページ'];
    List<Widget> bodies = [
      UserNoticeScreen(userProvider: userProvider),
      SendScreen(userProvider: userProvider),
      UserScreen(userProvider: userProvider),
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text(titles[currentIndex]),
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
      body: Column(
        children: [
          inAppPurchaseProvider.planAdView && bannerAd.responseInfo != null
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
              title: '受信履歴',
            ),
            NavBarItems(
              icon: FontAwesomeIcons.paperPlane,
              title: '送信履歴',
            ),
            NavBarItems(
              icon: FontAwesomeIcons.user,
              title: 'マイページ',
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
