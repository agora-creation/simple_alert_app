import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:page_transition/page_transition.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:provider/provider.dart';
import 'package:simple_alert_app/common/functions.dart';
import 'package:simple_alert_app/common/style.dart';
import 'package:simple_alert_app/models/user.dart';
import 'package:simple_alert_app/models/user_noticer.dart';
import 'package:simple_alert_app/providers/in_app_purchase.dart';
import 'package:simple_alert_app/providers/user.dart';
import 'package:simple_alert_app/screens/home.dart';
import 'package:simple_alert_app/screens/send_setting_name.dart';
import 'package:simple_alert_app/screens/send_setting_users.dart';
import 'package:simple_alert_app/services/user_noticer.dart';
import 'package:simple_alert_app/services/user_send.dart';
import 'package:simple_alert_app/widgets/setting_list.dart';

class SendSettingScreen extends StatefulWidget {
  final UserProvider userProvider;

  const SendSettingScreen({
    required this.userProvider,
    super.key,
  });

  @override
  State<SendSettingScreen> createState() => _SendSettingScreenState();
}

class _SendSettingScreenState extends State<SendSettingScreen> {
  int monthSendCount = 0;

  void _init() async {
    if (widget.userProvider.user != null) {
      monthSendCount = await UserSendService().selectMonthSendCount(
        userId: widget.userProvider.user!.id,
      );
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  Widget build(BuildContext context) {
    UserModel? user = widget.userProvider.user;
    String userId = user?.id ?? '';
    String qrData = 'AGORA-$userId';
    return Scaffold(
      backgroundColor: kWhiteColor,
      appBar: AppBar(
        backgroundColor: kWhiteColor,
        automaticallyImplyLeading: false,
        title: const Text(
          '送信者設定',
          style: TextStyle(color: kBlackColor),
        ),
        actions: [
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.xmark),
            onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          children: [
            Align(
              alignment: Alignment.center,
              child: Text('受信者に、下記QRコードを見せてください。'),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 8,
                horizontal: 24,
              ),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: kBlackColor.withOpacity(0.5)),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(24),
                child: PrettyQrView.data(data: qrData),
              ),
            ),
            SettingList(
              label: '送信者名',
              trailing: Text(
                user?.senderName ?? '',
                style: TextStyle(
                  color: kBlackColor,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'SourceHanSansJP-Bold',
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  PageTransition(
                    type: PageTransitionType.rightToLeft,
                    child: SendSettingNameScreen(
                      userProvider: widget.userProvider,
                    ),
                  ),
                );
              },
            ),
            StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: UserNoticerService().streamList(userId: userId),
              builder: (context, snapshot) {
                List<UserNoticerModel> userNoticers = [];
                if (snapshot.hasData) {
                  userNoticers = UserNoticerService().generateList(
                    data: snapshot.data,
                  );
                }
                return SettingList(
                  label: '登録された受信者一覧 (${userNoticers.length})',
                  trailing: const FaIcon(
                    FontAwesomeIcons.chevronRight,
                    size: 16,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      PageTransition(
                        type: PageTransitionType.rightToLeft,
                        child: SendSettingUsersScreen(
                          userProvider: widget.userProvider,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
            SettingList(
              label: 'ご利用中のプラン',
              subtitle: Text(
                'フリープラン',
                style: TextStyle(
                  color: kRedColor,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'SourceHanSansJP-Bold',
                ),
              ),
              trailing: const FaIcon(
                FontAwesomeIcons.pen,
                size: 16,
              ),
              onTap: () async {
                final inAppPurchaseProvider =
                    context.read<InAppPurchaseProvider>();
                String? purchasePlan = await getPrefsString('purchasePlan');
                if (purchasePlan != null) {
                  inAppPurchaseProvider.selectedProductId = purchasePlan;
                }
                showInAppPurchaseDialog(
                  context,
                  result: (selectedProductId) async {
                    if (selectedProductId != kProductMaps[0]['id'].toString()) {
                      ProductDetails? selectedProduct;
                      if (inAppPurchaseProvider.availableProducts.isNotEmpty) {
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
                        if (!mounted) return;
                        Navigator.pushReplacement(
                          context,
                          PageTransition(
                            type: PageTransitionType.bottomToTop,
                            child: HomeScreen(),
                          ),
                        );
                      } else {
                        if (context.mounted) {
                          print(purchaseResult.$2);
                        }
                      }
                    } else {
                      if (!mounted) return;
                      Navigator.pushReplacement(
                        context,
                        PageTransition(
                          type: PageTransitionType.bottomToTop,
                          child: HomeScreen(),
                        ),
                      );
                    }
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
