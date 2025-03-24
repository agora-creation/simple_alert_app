import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:simple_alert_app/common/style.dart';
import 'package:simple_alert_app/models/user.dart';
import 'package:simple_alert_app/models/user_notice.dart';
import 'package:simple_alert_app/providers/user.dart';
import 'package:simple_alert_app/screens/user_notice_detail.dart';
import 'package:simple_alert_app/screens/user_notice_user.dart';
import 'package:simple_alert_app/services/user_notice.dart';
import 'package:simple_alert_app/widgets/custom_button.dart';
import 'package:simple_alert_app/widgets/user_notice_list.dart';

class UserNoticeScreen extends StatelessWidget {
  final UserProvider userProvider;

  const UserNoticeScreen({
    required this.userProvider,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    UserModel? user = userProvider.user;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(top: 8, left: 16, right: 16),
        child: Card(
          color: kWhiteColor,
          elevation: 0,
          shape: RoundedRectangleBorder(),
          child: userProvider.loginCheck()
              ? Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CustomButton(
                            type: ButtonSizeType.sm,
                            label: '受信先一覧 (${user?.mapNoticeUsers.length})',
                            labelColor: kBlackColor,
                            backgroundColor: kBlackColor.withOpacity(0.3),
                            onPressed: () {
                              Navigator.push(
                                context,
                                PageTransition(
                                  type: PageTransitionType.rightToLeft,
                                  child: UserNoticeUserScreen(
                                    userProvider: userProvider,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    Divider(height: 0, color: kBlackColor.withOpacity(0.5)),
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
                      ),
                    ),
                  ],
                )
              : Center(
                  child: Container(
                    color: kRedColor,
                    padding: EdgeInsets.all(8),
                    child: Text(
                      'マイページから登録・ログインしてください',
                      style: TextStyle(
                        color: kWhiteColor,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'SourceHanSansJP-Bold',
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
