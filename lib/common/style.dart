import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const kAppShortName = 'B-Alert';

const kBackgroundColor = Color(0xFFFFF176);
const kWhiteColor = Color(0xFFFFFFFF);
const kBlackColor = Color(0xFF333333);
const kRedColor = Color(0xFFF44336);
const kBlueColor = Color(0xFF2196F3);

ThemeData customTheme() {
  return ThemeData(
    scaffoldBackgroundColor: kBackgroundColor,
    fontFamily: 'SourceHanSansJP-Regular',
    appBarTheme: const AppBarTheme(
      backgroundColor: kBackgroundColor,
      elevation: 0,
      centerTitle: false,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
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
