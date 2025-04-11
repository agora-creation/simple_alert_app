import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:simple_alert_app/common/functions.dart';
import 'package:simple_alert_app/common/style.dart';
import 'package:simple_alert_app/models/user_notice.dart';
import 'package:simple_alert_app/models/user_send.dart';
import 'package:simple_alert_app/providers/in_app_purchase.dart';
import 'package:simple_alert_app/providers/user.dart';
import 'package:simple_alert_app/screens/info.dart';
import 'package:simple_alert_app/screens/notice_detail.dart';
import 'package:simple_alert_app/screens/notice_setting.dart';
import 'package:simple_alert_app/screens/send_detail.dart';
import 'package:simple_alert_app/screens/send_input.dart';
import 'package:simple_alert_app/screens/send_setting.dart';
import 'package:simple_alert_app/services/ad.dart';
import 'package:simple_alert_app/services/user_notice.dart';
import 'package:simple_alert_app/services/user_send.dart';
import 'package:simple_alert_app/widgets/custom_bottom_sheet.dart';
import 'package:simple_alert_app/widgets/custom_card.dart';
import 'package:simple_alert_app/widgets/custom_list_button.dart';
import 'package:simple_alert_app/widgets/user_notice_list.dart';
import 'package:simple_alert_app/widgets/user_send_list.dart';

class HomeScreen extends StatefulWidget {
  final int mode;

  const HomeScreen({
    this.mode = 0,
    super.key,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  BannerAd bannerAd = AdService.createBannerAd();

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
    // context.read<InAppPurchaseProvider>().dispose();
    // bannerAd.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final inAppPurchaseProvider = context.read<InAppPurchaseProvider>();
    String modeText = '受信モード';
    if (widget.mode == 1) {
      modeText = '送信モード';
    }
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('$kAppShortName: $modeText'),
        actions: [
          widget.mode == 1
              ? IconButton(
                  icon: const FaIcon(FontAwesomeIcons.earListen),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      PageTransition(
                        type: PageTransitionType.leftToRight,
                        child: HomeScreen(),
                      ),
                    );
                  },
                )
              : IconButton(
                  icon: const FaIcon(FontAwesomeIcons.paperPlane),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      PageTransition(
                        type: PageTransitionType.rightToLeft,
                        child: HomeScreen(mode: 1),
                      ),
                    );
                  },
                ),
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.ellipsisVertical),
            onPressed: () => showBottomUpScreen(
              context,
              InfoScreen(userProvider: userProvider),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            inAppPurchaseProvider.planAdView && bannerAd.responseInfo != null
                ? SizedBox(
                    width: bannerAd.size.width.toDouble(),
                    height: bannerAd.size.height.toDouble(),
                    child: AdWidget(ad: bannerAd),
                  )
                : Container(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 16,
                  right: 16,
                  bottom: 8,
                ),
                child: widget.mode == 1
                    ? SendCard(userProvider: userProvider)
                    : NoticeCard(userProvider: userProvider),
              ),
            ),
          ],
        ),
      ),
      bottomSheet: CustomBottomSheet(),
    );
  }
}

class NoticeCard extends StatelessWidget {
  final UserProvider userProvider;

  const NoticeCard({
    required this.userProvider,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      child: Column(
        children: [
          CustomListButton(
            leadingIcon: FontAwesomeIcons.gear,
            label: '受信設定',
            labelColor: kBlackColor,
            tileColor: kBlackColor.withOpacity(0.3),
            onTap: () => showBottomUpScreen(
              context,
              NoticeSettingScreen(
                userProvider: userProvider,
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: UserNoticeService().streamList(
                userId: userProvider.user?.id ?? 'error',
              ),
              builder: (context, snapshot) {
                List<UserNoticeModel> userNotices = [];
                if (snapshot.hasData) {
                  userNotices = UserNoticeService().generateList(
                    data: snapshot.data,
                  );
                }
                if (userNotices.isEmpty) {
                  return Center(
                    child: Text(
                      '受信履歴はありません',
                      style: TextStyle(fontSize: 14),
                    ),
                  );
                }
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: userNotices.length,
                  itemBuilder: (context, index) {
                    UserNoticeModel userNotice = userNotices[index];
                    return UserNoticeList(
                      userNotice: userNotice,
                      onTap: () {
                        Navigator.push(
                          context,
                          PageTransition(
                            type: PageTransitionType.rightToLeft,
                            child: NoticeDetailScreen(
                              userProvider: userProvider,
                              userNotice: userNotice,
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class SendCard extends StatelessWidget {
  final UserProvider userProvider;

  const SendCard({
    required this.userProvider,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      child: Column(
        children: [
          CustomListButton(
            leadingIcon: FontAwesomeIcons.gear,
            label: '送信設定',
            labelColor: kBlackColor,
            tileColor: kBlackColor.withOpacity(0.3),
            onTap: () => showBottomUpScreen(
              context,
              SendSettingScreen(
                userProvider: userProvider,
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: UserSendService().streamList(
                userId: userProvider.user?.id ?? 'error',
              ),
              builder: (context, snapshot) {
                List<UserSendModel> userSends = [];
                if (snapshot.hasData) {
                  userSends = UserSendService().generateList(
                    data: snapshot.data,
                  );
                }
                if (userSends.isEmpty) {
                  return Center(
                    child: Text(
                      '送信履歴はありません',
                      style: TextStyle(fontSize: 14),
                    ),
                  );
                }
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: userSends.length,
                  itemBuilder: (context, index) {
                    UserSendModel userSend = userSends[index];
                    return UserSendList(
                      userSend: userSend,
                      onTap: () {
                        if (userSend.draft) {
                          showBottomUpScreen(
                            context,
                            SendInputScreen(
                              userProvider: userProvider,
                              userSend: userSend,
                            ),
                          );
                        } else {
                          Navigator.push(
                            context,
                            PageTransition(
                              type: PageTransitionType.rightToLeft,
                              child: SendDetailScreen(
                                userSend: userSend,
                              ),
                            ),
                          );
                        }
                      },
                    );
                  },
                );
              },
            ),
          ),
          CustomListButton(
            leadingIcon: FontAwesomeIcons.pen,
            label: 'メッセージを作成',
            labelColor: kWhiteColor,
            tileColor: kBlueColor,
            onTap: () => showBottomUpScreen(
              context,
              SendInputScreen(
                userProvider: userProvider,
              ),
            ),
            verticalAlign: ButtonVerticalAlign.bottom,
          ),
        ],
      ),
    );
  }
}
