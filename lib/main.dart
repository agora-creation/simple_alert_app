import 'dart:async';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:simple_alert_app/common/style.dart';
import 'package:simple_alert_app/providers/in_app_purchase.dart';
import 'package:simple_alert_app/providers/user.dart';
import 'package:simple_alert_app/screens/login.dart';
import 'package:simple_alert_app/screens/notice.dart';
import 'package:simple_alert_app/screens/send.dart';
import 'package:simple_alert_app/screens/splash.dart';
import 'package:simple_alert_app/services/push.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Platform.isAndroid
      ? await Firebase.initializeApp(
          options: const FirebaseOptions(
            apiKey: 'AIzaSyAxTKeHtsyHLYidtdrY27byAxqQckpTzOU',
            appId: '1:44926072077:android:36f188621c8ec660d62c44',
            messagingSenderId: '44926072077',
            projectId: 'simple-alert-project',
            storageBucket: 'simple-alert-project.firebasestorage.app',
          ),
        )
      : await Firebase.initializeApp();
  //通知サービスの初期化
  PushService().init();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarBrightness: Brightness.dark,
    statusBarIconBrightness: Brightness.dark,
  ));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: UserProvider.initialize()),
        ChangeNotifierProvider(create: (context) => InAppPurchaseProvider()),
      ],
      child: MaterialApp(
        builder: (context, child) {
          return MediaQuery.withNoTextScaling(
            child: child!,
          );
        },
        debugShowCheckedModeBanner: false,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('ja')],
        locale: const Locale('ja'),
        title: kAppShortName,
        theme: customTheme(),
        home: const SplashController(),
      ),
    );
  }
}

class SplashController extends StatelessWidget {
  const SplashController({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    switch (userProvider.status) {
      case AuthStatus.uninitialized:
        return const SplashScreen();
      case AuthStatus.unauthenticated:
      case AuthStatus.authenticating:
        return const LoginScreen();
      case AuthStatus.authenticated:
        if (userProvider.currentMode == Mode.notice) {
          return const NoticeScreen();
        } else if (userProvider.currentMode == Mode.send) {
          return const SendScreen();
        }
        return const SplashScreen();
    }
  }
}
