import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:simple_alert_app/common/functions.dart';
import 'package:simple_alert_app/common/style.dart';
import 'package:simple_alert_app/models/user_notice.dart';
import 'package:simple_alert_app/models/user_sender.dart';
import 'package:simple_alert_app/providers/in_app_purchase.dart';
import 'package:simple_alert_app/providers/user.dart';
import 'package:simple_alert_app/screens/info.dart';
import 'package:simple_alert_app/screens/notice_detail.dart';
import 'package:simple_alert_app/screens/notice_user.dart';
import 'package:simple_alert_app/screens/send.dart';
import 'package:simple_alert_app/services/ad.dart';
import 'package:simple_alert_app/services/user_notice.dart';
import 'package:simple_alert_app/services/user_sender.dart';
import 'package:simple_alert_app/widgets/custom_bottom_sheet.dart';
import 'package:simple_alert_app/widgets/custom_card.dart';
import 'package:simple_alert_app/widgets/custom_list_button.dart';
import 'package:simple_alert_app/widgets/user_notice_list.dart';

class NoticeScreen extends StatefulWidget {
  const NoticeScreen({super.key});

  @override
  State<NoticeScreen> createState() => _NoticeScreenState();
}

class _NoticeScreenState extends State<NoticeScreen> {
  BannerAd bannerAd = AdService.createBannerAd();

  void _initBannerAd() async {
    await bannerAd.load();
  }

  @override
  void initState() {
    _initBannerAd();
    context.read<InAppPurchaseProvider>().initialize();
    super.initState();
  }

  @override
  void dispose() {
    // bannerAd.dispose();
    // context.read<InAppPurchaseProvider>().dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('$kAppShortName: 受信モード'),
        actions: [
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.rotate),
            onPressed: () async {
              await userProvider.modeChange(Mode.send);
              Navigator.pushReplacement(
                context,
                PageTransition(
                  type: PageTransitionType.bottomToTop,
                  child: SendScreen(),
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
            bannerAd.responseInfo != null
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
                  bottom: 16,
                ),
                child: CustomCard(
                  child: Column(
                    children: [
                      StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                        stream: UserSenderService().streamList(
                          userId: userProvider.user?.id ?? 'error',
                        ),
                        builder: (context, snapshot) {
                          List<UserSenderModel> userSenders = [];
                          if (snapshot.hasData) {
                            userSenders = UserSenderService().generateList(
                              data: snapshot.data,
                            );
                          }
                          return CustomListButton(
                            leadingIcon: FontAwesomeIcons.list,
                            label: '受信先一覧 (${userSenders.length})',
                            labelColor: kBlackColor,
                            tileColor: kBlackColor.withOpacity(0.3),
                            onTap: () => showBottomUpScreen(
                              context,
                              NoticeUserScreen(
                                userProvider: userProvider,
                              ),
                            ),
                          );
                        },
                      ),
                      Expanded(
                        child:
                            StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
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
                                  style: TextStyle(
                                    color: kBlackColor.withOpacity(0.5),
                                    fontSize: 20,
                                  ),
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
                ),
              ),
            ),
          ],
        ),
      ),
      bottomSheet: CustomBottomSheet(),
    );
  }
}
