import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:page_transition/page_transition.dart';
import 'package:simple_alert_app/common/functions.dart';
import 'package:simple_alert_app/common/style.dart';
import 'package:simple_alert_app/models/user.dart';
import 'package:simple_alert_app/models/user_send.dart';
import 'package:simple_alert_app/providers/user.dart';
import 'package:simple_alert_app/screens/send_create.dart';
import 'package:simple_alert_app/screens/send_detail.dart';
import 'package:simple_alert_app/screens/send_user.dart';
import 'package:simple_alert_app/services/user_send.dart';
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
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Card(
          margin: EdgeInsets.zero,
          color: kWhiteColor,
          elevation: 0,
          shape: RoundedRectangleBorder(),
          child: Column(
            children: [
              ListTile(
                title: Text('送信先を確認 (${user?.sendMapUsers.length})'),
                tileColor: kBlueColor.withOpacity(0.3),
                trailing: FaIcon(
                  FontAwesomeIcons.chevronUp,
                  size: 16,
                ),
                onTap: () => showBottomUpScreen(
                  context,
                  SendUserScreen(
                    userProvider: userProvider,
                  ),
                ),
              ),
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
              ListTile(
                title: Text(
                  'メッセージを作成',
                  style: TextStyle(color: kWhiteColor),
                ),
                tileColor: kBlueColor,
                trailing: FaIcon(
                  FontAwesomeIcons.plus,
                  size: 16,
                  color: kWhiteColor,
                ),
                onTap: () => showBottomUpScreen(
                  context,
                  SendCreateScreen(
                    userProvider: userProvider,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
