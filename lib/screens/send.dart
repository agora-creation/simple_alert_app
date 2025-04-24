import 'package:app_tutorial/app_tutorial.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:simple_alert_app/common/functions.dart';
import 'package:simple_alert_app/common/style.dart';
import 'package:simple_alert_app/models/user.dart';
import 'package:simple_alert_app/models/user_send.dart';
import 'package:simple_alert_app/providers/in_app_purchase.dart';
import 'package:simple_alert_app/providers/user.dart';
import 'package:simple_alert_app/screens/info.dart';
import 'package:simple_alert_app/screens/notice.dart';
import 'package:simple_alert_app/screens/send_create.dart';
import 'package:simple_alert_app/screens/send_detail.dart';
import 'package:simple_alert_app/screens/send_setting.dart';
import 'package:simple_alert_app/services/ad.dart';
import 'package:simple_alert_app/services/user_send.dart';
import 'package:simple_alert_app/widgets/alert_bar.dart';
import 'package:simple_alert_app/widgets/custom_bottom_sheet.dart';
import 'package:simple_alert_app/widgets/custom_button.dart';
import 'package:simple_alert_app/widgets/custom_card.dart';
import 'package:simple_alert_app/widgets/custom_list_button.dart';
import 'package:simple_alert_app/widgets/custom_text_form_field.dart';
import 'package:simple_alert_app/widgets/user_send_list.dart';

class SendScreen extends StatefulWidget {
  const SendScreen({super.key});

  @override
  State<SendScreen> createState() => _SendScreenState();
}

class _SendScreenState extends State<SendScreen> {
  BannerAd bannerAd = AdService.createBannerAd();
  GlobalKey tutorial1Key = GlobalKey();
  GlobalKey tutorial2Key = GlobalKey();
  GlobalKey tutorial3Key = GlobalKey();
  List<TutorialItem> tutorialItems = [];

  void _initBannerAd() async {
    await bannerAd.load();
  }

  void _initTutorial() async {
    bool sendTutorial = await getPrefsBool('sendTutorial') ?? false;
    if (sendTutorial) return;
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
                  '送信者設定',
                  style: TextStyle(
                    color: kWhiteColor,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'SourceHanSansJP-Bold',
                  ),
                ),
                Text(
                  'このボタンをタップすると、送信に関する様々な設定を確認できます。',
                  style: TextStyle(
                    color: kWhiteColor,
                    fontSize: 16,
                  ),
                ),
                Text(
                  '● 送信者QRコードの表示',
                  style: TextStyle(
                    color: kWhiteColor,
                    fontSize: 16,
                  ),
                ),
                Text(
                  '● 送信者名の変更',
                  style: TextStyle(
                    color: kWhiteColor,
                    fontSize: 16,
                  ),
                ),
                Text(
                  '● 登録された受信者の確認',
                  style: TextStyle(
                    color: kWhiteColor,
                    fontSize: 16,
                  ),
                ),
                Text(
                  '● 受信者をグループで分ける',
                  style: TextStyle(
                    color: kWhiteColor,
                    fontSize: 16,
                  ),
                ),
                Text(
                  '● プランの変更',
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
                  '通知の送信履歴',
                  style: TextStyle(
                    color: kBlackColor,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'SourceHanSansJP-Bold',
                  ),
                ),
                Text(
                  'ここに送信履歴一覧が表示されます。下書き中のデータも確認できます。',
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
        globalKey: tutorial3Key,
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
                  'メッセージの作成',
                  style: TextStyle(
                    color: kWhiteColor,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'SourceHanSansJP-Bold',
                  ),
                ),
                Text(
                  'このボタンをタップすると、通知内容を作成することができます。下書き保存も可能です。',
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
          await setPrefsBool('sendTutorial', true);
        },
      );
    });
  }

  Future<String> fetchMonthSendCount(UserModel? user) async {
    int monthSendCount = 0;
    int monthSendLimit = 0;
    if (user != null) {
      monthSendCount = await UserSendService().selectMonthSendCount(
        userId: user.id,
      );
    }
    monthSendLimit = await getMonthSendLimit();
    return '現在$monthSendCount件 / 月$monthSendLimit件まで送信可';
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
        title: Text('$kAppShortName: 送信モード'),
        actions: [
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.rotate),
            onPressed: () async {
              await userProvider.modeChange(Mode.notice);
              Navigator.pushReplacement(
                context,
                PageTransition(
                  type: PageTransitionType.bottomToTop,
                  child: NoticeScreen(),
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
                child: userProvider.user?.sender == true
                    ? CustomCard(
                        child: Column(
                          children: [
                            CustomListButton(
                              key: tutorial1Key,
                              leadingIcon: FontAwesomeIcons.gear,
                              label: '送信者設定',
                              labelColor: kBlackColor,
                              tileColor: kBlackColor.withOpacity(0.3),
                              onTap: () => showBottomUpScreen(
                                context,
                                SendSettingScreen(
                                  userProvider: userProvider,
                                ),
                              ),
                            ),
                            FutureBuilder<String>(
                              future: fetchMonthSendCount(userProvider.user),
                              builder: (context, snapshot) {
                                if (snapshot.data != null) {
                                  return AlertBar(snapshot.data ?? '');
                                } else {
                                  return Container();
                                }
                              },
                            ),
                            Expanded(
                              key: tutorial2Key,
                              child: StreamBuilder<
                                  QuerySnapshot<Map<String, dynamic>>>(
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
                                        style: TextStyle(
                                          color: kBlackColor.withOpacity(0.5),
                                          fontSize: 20,
                                        ),
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
                                              SendCreateScreen(
                                                userProvider: userProvider,
                                                userSend: userSend,
                                              ),
                                            );
                                          } else {
                                            Navigator.push(
                                              context,
                                              PageTransition(
                                                type: PageTransitionType
                                                    .rightToLeft,
                                                child: SendDetailScreen(
                                                  userProvider: userProvider,
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
                              key: tutorial3Key,
                              leadingIcon: FontAwesomeIcons.pen,
                              label: 'メッセージを作成',
                              labelColor: kWhiteColor,
                              tileColor: kBlueColor,
                              onTap: () => showBottomUpScreen(
                                context,
                                SendCreateScreen(
                                  userProvider: userProvider,
                                ),
                              ),
                              verticalAlign: ButtonVerticalAlign.bottom,
                            ),
                          ],
                        ),
                      )
                    : SendLoginWidget(userProvider: userProvider),
              ),
            ),
          ],
        ),
      ),
      bottomSheet: CustomBottomSheet(),
    );
  }
}

class SendLoginWidget extends StatefulWidget {
  final UserProvider userProvider;

  const SendLoginWidget({
    required this.userProvider,
    super.key,
  });

  @override
  State<SendLoginWidget> createState() => _SendLoginWidgetState();
}

class _SendLoginWidgetState extends State<SendLoginWidget> {
  TextEditingController senderNameController = TextEditingController();

  @override
  void initState() {
    senderNameController.text = widget.userProvider.user?.name ?? '';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      behavior: HitTestBehavior.opaque,
      child: CustomCard(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  Text(
                    '- はじめに -',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'SourceHanSansJP-Bold',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '送信モードを利用するには、送信者名を入力して、ご利用プランを選んでください。',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
              Column(
                children: [
                  CustomTextFormField(
                    controller: senderNameController,
                    textInputType: TextInputType.name,
                    maxLines: 1,
                    label: '送信者名',
                    color: kBlackColor,
                    prefix: Icons.account_box,
                    fillColor: kBlackColor.withOpacity(0.1),
                  ),
                  const SizedBox(height: 16),
                  CustomButton(
                    type: ButtonSizeType.lg,
                    label: 'ご利用プランを選ぶ',
                    labelColor: kWhiteColor,
                    backgroundColor: kBlueColor,
                    onPressed: () {
                      if (senderNameController.text == '') {
                        if (!mounted) return;
                        showMessage(context, '送信者名を入力してください', false);
                        return;
                      }
                      final inAppPurchaseProvider =
                          context.read<InAppPurchaseProvider>();
                      showInAppPurchaseDialog(
                        context,
                        result: (selectedProductId) async {
                          if (selectedProductId !=
                              kProductMaps[0]['id'].toString()) {
                            ProductDetails? selectedProduct;
                            if (inAppPurchaseProvider
                                .availableProducts.isNotEmpty) {
                              for (final product
                                  in inAppPurchaseProvider.availableProducts) {
                                if (product.id == selectedProductId) {
                                  selectedProduct = product;
                                  break;
                                }
                              }
                            }
                            final purchaseResult = await inAppPurchaseProvider
                                .purchaseProduct(selectedProduct!);
                            if (purchaseResult.$1 && context.mounted) {
                              print('購入成功');
                              String? error =
                                  await widget.userProvider.updateSender(
                                senderName: senderNameController.text,
                              );
                              if (error != null) {
                                if (!mounted) return;
                                showMessage(context, error, false);
                                return;
                              }
                              await widget.userProvider.reload();
                              if (!mounted) return;
                              Navigator.pushReplacement(
                                context,
                                PageTransition(
                                  type: PageTransitionType.bottomToTop,
                                  child: SendScreen(),
                                ),
                              );
                            } else {
                              if (context.mounted) {
                                print(purchaseResult.$2);
                              }
                            }
                          } else {
                            String? error =
                                await widget.userProvider.updateSender(
                              senderName: senderNameController.text,
                            );
                            if (error != null) {
                              if (!mounted) return;
                              showMessage(context, error, false);
                              return;
                            }
                            await widget.userProvider.reload();
                            if (!mounted) return;
                            Navigator.pushReplacement(
                              context,
                              PageTransition(
                                type: PageTransitionType.bottomToTop,
                                child: SendScreen(),
                              ),
                            );
                          }
                        },
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
