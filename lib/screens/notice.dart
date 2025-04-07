import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:page_transition/page_transition.dart';
import 'package:simple_alert_app/common/functions.dart';
import 'package:simple_alert_app/common/style.dart';
import 'package:simple_alert_app/models/user.dart';
import 'package:simple_alert_app/models/user_notice.dart';
import 'package:simple_alert_app/providers/user.dart';
import 'package:simple_alert_app/screens/notice_detail.dart';
import 'package:simple_alert_app/screens/notice_setting.dart';
import 'package:simple_alert_app/services/user_notice.dart';
import 'package:simple_alert_app/widgets/user_notice_list.dart';

class NoticeScreen extends StatelessWidget {
  final UserProvider userProvider;

  const NoticeScreen({
    required this.userProvider,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    UserModel? user = userProvider.user;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Card(
          margin: EdgeInsets.zero,
          color: kWhiteColor,
          elevation: 0,
          shape: RoundedRectangleBorder(),
          child: Column(
            children: [
              ListTile(
                title: Text('受信設定'),
                tileColor: kBlackColor.withOpacity(0.3),
                trailing: FaIcon(
                  FontAwesomeIcons.userGear,
                  size: 16,
                ),
                onTap: () => showBottomUpScreen(
                  context,
                  NoticeSettingScreen(
                    userProvider: userProvider,
                  ),
                ),
              ),
              Expanded(
                child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: UserNoticeService().streamList(
                    userId: user?.id ?? 'error',
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
                          '受信履歴はありません',
                          style: TextStyle(fontSize: 14),
                        ),
                      );
                    }
                    return ListView.builder(
                      shrinkWrap: true,
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
                                child: NoticeDetailScreen(
                                  userProvider: userProvider,
                                  userNotice: userNotice,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
