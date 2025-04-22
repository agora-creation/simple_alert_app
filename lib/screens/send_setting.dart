import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gallery_saver_plus/gallery_saver.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:page_transition/page_transition.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
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
  GlobalKey qrcodeKey = GlobalKey();
  int monthSendCount = 0;

  void _init() async {
    if (widget.userProvider.user != null) {
      monthSendCount = await UserSendService().selectMonthSendCount(
        userId: widget.userProvider.user!.id,
      );
    }
    setState(() {});
  }

  Future _requestPermission() async {
    if (Platform.isAndroid) {
      await Permission.storage.request();
      await Permission.photos.request();
    } else if (Platform.isIOS) {
      await Permission.photosAddOnly.request();
    }
  }

  Future _saveQrToGallery() async {
    //パーミッション確認
    await _requestPermission();
    try {
      RenderRepaintBoundary boundary =
          qrcodeKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();
      //一時ファイルに保存
      final tmpDir = await getTemporaryDirectory();
      String filePath = '${tmpDir.path}/qr_code.png';
      File file = await File(filePath).writeAsBytes(pngBytes);
      //ギャラリーに保存
      await GallerySaver.saveImage(file.path, albumName: 'QR_Codes');
      showMessage(context, 'QRコードを保存しました', true);
    } catch (e) {
      print(e);
    }
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
        child: Column(
          children: [
            AlertBar('受信者に、下記QRコードを見せてください。'),
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 40,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  GestureDetector(
                    onLongPress: _saveQrToGallery,
                    child: RepaintBoundary(
                      key: qrcodeKey,
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: kBlackColor.withOpacity(0.5),
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.all(24),
                        child: PrettyQrView.data(data: qrData),
                      ),
                    ),
                  ),
                ],
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
