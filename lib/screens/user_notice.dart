import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:simple_alert_app/common/style.dart';
import 'package:simple_alert_app/screens/user_notice_detail.dart';
import 'package:simple_alert_app/widgets/notice_list.dart';

class UserNoticeScreen extends StatelessWidget {
  const UserNoticeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Card(
          color: kWhiteColor,
          elevation: 0,
          child: ListView.builder(
            itemCount: 100,
            itemBuilder: (context, index) {
              return NoticeList(
                titleLabel: '休業のお知らせ',
                onTap: () {
                  Navigator.push(
                    context,
                    PageTransition(
                      type: PageTransitionType.rightToLeft,
                      child: UserNoticeDetailScreen(),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
