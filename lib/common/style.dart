import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const kAppShortName = 'B-Alert';

const kBackgroundColor = Color(0xFFFFF176);
const kWhiteColor = Color(0xFFFFFFFF);
const kBlackColor = Color(0xFF333333);
const kRedColor = Color(0xFFF44336);
const kBlueColor = Color(0xFF2196F3);
const kMsgBgColor = Color(0xFFF5F5F5);

ThemeData customTheme() {
  return ThemeData(
    scaffoldBackgroundColor: kBackgroundColor,
    fontFamily: 'SourceHanSansJP-Regular',
    appBarTheme: const AppBarTheme(
      backgroundColor: kBackgroundColor,
      elevation: 0,
      centerTitle: false,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      titleTextStyle: TextStyle(
        color: kBlackColor,
        fontSize: 20,
        fontWeight: FontWeight.bold,
        fontFamily: 'SourceHanSansJP-Bold',
      ),
      iconTheme: IconThemeData(
        color: kBlackColor,
        size: 18,
      ),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: kBlackColor, fontSize: 16),
      bodyMedium: TextStyle(color: kBlackColor, fontSize: 16),
      bodySmall: TextStyle(color: kBlackColor, fontSize: 16),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: kBlueColor,
      elevation: 0,
      extendedTextStyle: TextStyle(
        color: kWhiteColor,
        fontSize: 18,
        fontWeight: FontWeight.bold,
        fontFamily: 'SourceHanSansJP-Bold',
      ),
    ),
    visualDensity: VisualDensity.adaptivePlatformDensity,
    unselectedWidgetColor: kWhiteColor,
  );
}

const kChoices = ['はい', 'いいえ'];

List<String> kProductIds = ['subscription_standard', 'subscription_pro'];
const List<Map<String, String>> kProductMaps = [
  {
    'id': 'subscription_free',
    'title': 'フリープラン',
    'description': '1ヶ月に10件まで送信可能になります。',
    'price': '¥0/月',
  },
  {
    'id': 'subscription_standard',
    'title': 'スタンダードプラン',
    'description': '1ヶ月に100件まで送信可能になり、バナー広告が非表示になります。',
    'price': '¥900/月',
  },
  {
    'id': 'subscription_pro',
    'title': 'プロプラン',
    'description': '1ヶ月に1000件まで送信可能になり、バナー広告が非表示になります。',
    'price': '¥1,800/月',
  },
];
