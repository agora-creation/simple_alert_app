import 'package:flutter/material.dart';
import 'package:simple_alert_app/common/style.dart';

class SignPanel extends StatelessWidget {
  final Widget signUpChild;
  final Widget signInChild;

  const SignPanel({
    required this.signUpChild,
    required this.signInChild,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 24),
      child: DefaultTabController(
        initialIndex: 0,
        length: 2,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TabBar(
              tabs: [
                Tab(text: '初めての方'),
                Tab(text: '既に登録済の方'),
              ],
              indicatorColor: kRedColor,
              labelColor: kBlackColor,
              unselectedLabelColor: kBlackColor.withOpacity(0.5),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  signUpChild,
                  signInChild,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
