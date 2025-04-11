import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:simple_alert_app/common/style.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  Text(
                    kAppShortName,
                    style: TextStyle(
                      color: kBlackColor,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'SourceHanSansJP-Bold',
                    ),
                  ),
                  Text(
                    '- 通知に特化したアプリ -',
                    style: TextStyle(
                      color: kBlackColor,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              SpinKitCircle(color: kBlackColor),
            ],
          ),
        ),
      ),
    );
  }
}
