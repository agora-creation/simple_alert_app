import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:simple_alert_app/common/style.dart';
import 'package:simple_alert_app/models/user_notice.dart';
import 'package:simple_alert_app/providers/user.dart';
import 'package:simple_alert_app/screens/user_notice_detail.dart';
import 'package:simple_alert_app/services/user_notice.dart';
import 'package:simple_alert_app/widgets/user_notice_list.dart';

class UserNoticeScreen extends StatelessWidget {
  final UserProvider userProvider;

  const UserNoticeScreen({
    required this.userProvider,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Card(
          color: kWhiteColor,
          elevation: 0,
          shape: RoundedRectangleBorder(),
          child: userProvider.loginCheck()
              ? StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: UserNoticeService().streamList(
                    userId: userProvider.user?.id ?? 'error',
                  ),
                  builder: (context, snapshot) {
                    List<UserNoticeModel> userNotices = [];
                    if (snapshot.hasData) {
                      userNotices = UserNoticeService().generateList(
                        data: snapshot.data,
                      );
                    }
                    if (userNotices.isEmpty) {
                      return Center(
                        child: Text(
                          '通知はありません',
                          style: TextStyle(fontSize: 14),
                        ),
                      );
                    }
                    return ListView.builder(
                      itemCount: userNotices.length,
                      itemBuilder: (context, index) {
                        UserNoticeModel userNotice = userNotices[index];
                        return UserNoticeList(
                          userNotice: userNotice,
                          onTap: () {
                            Navigator.push(
                              context,
                              PageTransition(
                                type: PageTransitionType.rightToLeft,
                                child: UserNoticeDetailScreen(
                                  userNotice: userNotice,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                )
              : Center(
                  child: Text(
                    'マイページから登録・ログインしてください',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
        ),
      ),
    );
  }
}
