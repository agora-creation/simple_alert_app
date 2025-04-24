import 'package:app_tutorial/app_tutorial.dart';
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
  GlobalKey tutorial1Key = GlobalKey();
  GlobalKey tutorial2Key = GlobalKey();
  List<TutorialItem> tutorialItems = [];

  void _initBannerAd() async {
    await bannerAd.load();
  }

  void _initTutorial() async {
    bool noticeTutorial = await getPrefsBool('noticeTutorial') ?? false;
    if (noticeTutorial) return;
    tutorialItems.clear();
    tutorialItems.addAll({
      TutorialItem(
        globalKey: tutorial1Key,
        color: kBlackColor.withOpacity(0.8),
        shapeFocus: ShapeFocus.square,
        borderRadius: const Radius.circular(0),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '通知の受信履歴',
                  style: TextStyle(
                    color: kBlackColor,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'SourceHanSansJP-Bold',
                  ),
                ),
                Text(
                  'ここに受信履歴一覧が表示されます。未読の通知は赤く表示されます。',
                  style: TextStyle(
                    color: kBlackColor,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      TutorialItem(
        globalKey: tutorial2Key,
        color: kBlackColor.withOpacity(0.8),
        shapeFocus: ShapeFocus.square,
        borderRadius: const Radius.circular(0),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '受信先一覧',
                  style: TextStyle(
                    color: kWhiteColor,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'SourceHanSansJP-Bold',
                  ),
                ),
                Text(
                  'このボタンをタップすると、現在登録している受信先一覧が確認できます。',
                  style: TextStyle(
                    color: kWhiteColor,
                    fontSize: 16,
                  ),
                ),
                Text(
                  '受信先の追加は、専用の送信者QRコードを読み取ることで追加することができます。',
                  style: TextStyle(
                    color: kWhiteColor,
                    fontSize: 16,
                  ),
                ),
                Text(
                  '()内の数字は、登録済みの受信先の件数です。',
                  style: TextStyle(
                    color: kWhiteColor,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    });
    Future.delayed(const Duration(seconds: 1)).then((value) {
      if (!mounted) return;
      Tutorial.showTutorial(
        context,
        tutorialItems,
        onTutorialComplete: () async {
          await setPrefsBool('noticeTutorial', true);
        },
      );
    });
  }

  @override
  void initState() {
    _initBannerAd();
    context.read<InAppPurchaseProvider>().initialize();
    _initTutorial();
    super.initState();
  }

  @override
  void dispose() {
    bannerAd.dispose();
    context.read<InAppPurchaseProvider>().dispose();
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
                            key: tutorial2Key,
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
                        key: tutorial1Key,
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
