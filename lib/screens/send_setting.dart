import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:page_transition/page_transition.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:simple_alert_app/common/functions.dart';
import 'package:simple_alert_app/common/style.dart';
import 'package:simple_alert_app/models/user.dart';
import 'package:simple_alert_app/models/user_noticer.dart';
import 'package:simple_alert_app/models/user_noticer_group.dart';
import 'package:simple_alert_app/providers/user.dart';
import 'package:simple_alert_app/screens/send_setting_group.dart';
import 'package:simple_alert_app/screens/send_setting_name.dart';
import 'package:simple_alert_app/screens/send_setting_user.dart';
import 'package:simple_alert_app/services/purchases.dart';
import 'package:simple_alert_app/services/user_noticer.dart';
import 'package:simple_alert_app/services/user_noticer_group.dart';
import 'package:simple_alert_app/services/user_send.dart';
import 'package:simple_alert_app/widgets/alert_bar.dart';
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
  String purchasesId = '';
  int monthSendCount = 0;

  void _initPurchasesListener() async {
    Purchases.addCustomerInfoUpdateListener((customerInfo) async {
      CustomerInfo customerInfo = await Purchases.getCustomerInfo();
      EntitlementInfo? entitlement =
          customerInfo.entitlements.all['subscription'];
      if (mounted) {
        setState(() {
          purchasesId = entitlement?.productIdentifier ?? '';
        });
      }
    });
  }

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
    _initPurchasesListener();
    _init();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    UserModel? user = widget.userProvider.user;
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
        child: Column(
          children: [
            AlertBar('受信者に『送信者ID』を伝えてください'),
            SettingList(
              label: '送信者ID',
              subtitle: Text(
                '※タップするとコピーできます',
                style: TextStyle(
                  color: kRedColor,
                  fontSize: 12,
                ),
              ),
              trailing: Text(
                user?.senderId ?? '',
                style: TextStyle(
                  color: kBlackColor,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'SourceHanSansJP-Bold',
                ),
              ),
              onTap: () async {
                final data = ClipboardData(
                  text: user?.senderId ?? '',
                );
                await Clipboard.setData(data);
                if (!mounted) return;
                showMessage(context, '送信者IDをコピーしました', true);
              },
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
              stream: UserNoticerService().streamList(
                userId: user?.id ?? 'error',
              ),
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
                        child: SendSettingUserScreen(
                          userProvider: widget.userProvider,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
            StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: UserNoticerGroupService().streamList(
                userId: user?.id ?? 'error',
              ),
              builder: (context, snapshot) {
                List<UserNoticerGroupModel> userNoticerGroups = [];
                if (snapshot.hasData) {
                  userNoticerGroups = UserNoticerGroupService().generateList(
                    data: snapshot.data,
                  );
                }
                return SettingList(
                  label: '受信者をグループ分け (${userNoticerGroups.length})',
                  trailing: const FaIcon(
                    FontAwesomeIcons.chevronRight,
                    size: 16,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      PageTransition(
                        type: PageTransitionType.rightToLeft,
                        child: SendSettingGroupScreen(
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
                PurchasesService().getName(purchasesId),
                style: TextStyle(
                  color: kRedColor,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'SourceHanSansJP-Bold',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
