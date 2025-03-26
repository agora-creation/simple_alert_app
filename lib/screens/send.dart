import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:simple_alert_app/common/style.dart';
import 'package:simple_alert_app/models/user.dart';
import 'package:simple_alert_app/models/user_send.dart';
import 'package:simple_alert_app/providers/user.dart';
import 'package:simple_alert_app/screens/send_create.dart';
import 'package:simple_alert_app/screens/send_detail.dart';
import 'package:simple_alert_app/screens/send_user.dart';
import 'package:simple_alert_app/services/user_send.dart';
import 'package:simple_alert_app/widgets/custom_button.dart';
import 'package:simple_alert_app/widgets/user_send_list.dart';

class SendScreen extends StatelessWidget {
  final UserProvider userProvider;

  const SendScreen({
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
                            label: '送信先一覧 (${user?.sendMapUsers.length})',
                            labelColor: kBlackColor,
                            backgroundColor: kBlackColor.withOpacity(0.3),
                            onPressed: () {
                              Navigator.push(
                                context,
                                PageTransition(
                                  type: PageTransitionType.rightToLeft,
                                  child: SendUserScreen(
                                    userProvider: userProvider,
                                  ),
                                ),
                              );
                            },
                          ),
                          CustomButton(
                            type: ButtonSizeType.sm,
                            label: '新規送信',
                            labelColor: kWhiteColor,
                            backgroundColor: kBlueColor,
                            onPressed: () {
                              Navigator.push(
                                context,
                                PageTransition(
                                  type: PageTransitionType.rightToLeft,
                                  child: SendCreateScreen(
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
                        stream: UserSendService().streamList(
                          userId: user?.id ?? 'error',
                        ),
                        builder: (context, snapshot) {
                          List<UserSendModel> userSends = [];
                          if (snapshot.hasData) {
                            userSends = UserSendService().generateList(
                              data: snapshot.data,
                            );
                          }
                          if (userSends.isEmpty) {
                            return Center(
                              child: Text(
                                '送信履歴はありません',
                                style: TextStyle(fontSize: 14),
                              ),
                            );
                          }
                          return ListView.builder(
                            shrinkWrap: true,
                            itemCount: userSends.length,
                            itemBuilder: (context, index) {
                              UserSendModel userSend = userSends[index];
                              return UserSendList(
                                userSend: userSend,
                                onTap: () {
                                  if (userSend.draft) {
                                    Navigator.push(
                                      context,
                                      PageTransition(
                                        type: PageTransitionType.rightToLeft,
                                        child: SendCreateScreen(
                                          userProvider: userProvider,
                                          userSend: userSend,
                                        ),
                                      ),
                                    );
                                  } else {
                                    Navigator.push(
                                      context,
                                      PageTransition(
                                        type: PageTransitionType.rightToLeft,
                                        child: SendDetailScreen(
                                          userSend: userSend,
                                        ),
                                      ),
                                    );
                                  }
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
