import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:page_transition/page_transition.dart';
import 'package:simple_alert_app/common/functions.dart';
import 'package:simple_alert_app/common/style.dart';
import 'package:simple_alert_app/models/user.dart';
import 'package:simple_alert_app/models/user_send.dart';
import 'package:simple_alert_app/providers/user.dart';
import 'package:simple_alert_app/screens/send_detail.dart';
import 'package:simple_alert_app/screens/send_input.dart';
import 'package:simple_alert_app/screens/send_setting.dart';
import 'package:simple_alert_app/services/user_send.dart';
import 'package:simple_alert_app/widgets/custom_list_button.dart';
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
              CustomListButton(
                leading: FaIcon(
                  FontAwesomeIcons.gear,
                  size: 16,
                ),
                label: '送信設定',
                tileColor: kBlackColor.withOpacity(0.3),
                trailing: FaIcon(
                  FontAwesomeIcons.chevronUp,
                  size: 16,
                ),
                onTap: () => showBottomUpScreen(
                  context,
                  SendSettingScreen(
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
                              showBottomUpScreen(
                                context,
                                SendInputScreen(
                                  userProvider: userProvider,
                                  userSend: userSend,
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
              CustomListButton(
                leading: FaIcon(
                  FontAwesomeIcons.pen,
                  size: 16,
                ),
                label: 'メッセージを作成',
                tileColor: kBlueColor.withOpacity(0.3),
                trailing: FaIcon(
                  FontAwesomeIcons.chevronUp,
                  size: 16,
                ),
                onTap: () => showBottomUpScreen(
                  context,
                  SendInputScreen(
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
