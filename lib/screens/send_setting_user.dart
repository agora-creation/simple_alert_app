import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:page_transition/page_transition.dart';
import 'package:simple_alert_app/common/style.dart';
import 'package:simple_alert_app/models/user.dart';
import 'package:simple_alert_app/models/user_noticer.dart';
import 'package:simple_alert_app/providers/user.dart';
import 'package:simple_alert_app/screens/send_setting_user_detail.dart';
import 'package:simple_alert_app/services/user_noticer.dart';
import 'package:simple_alert_app/widgets/user_noticer_list.dart';

class SendSettingUserScreen extends StatefulWidget {
  final UserProvider userProvider;

  const SendSettingUserScreen({
    required this.userProvider,
    super.key,
  });

  @override
  State<SendSettingUserScreen> createState() => _SendSettingUserScreenState();
}

class _SendSettingUserScreenState extends State<SendSettingUserScreen> {
  @override
  Widget build(BuildContext context) {
    UserModel? user = widget.userProvider.user;
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: UserNoticerService().streamList(userId: user?.id ?? 'error'),
      builder: (context, snapshot) {
        List<UserNoticerModel> userNoticers = [];
        if (snapshot.hasData) {
          userNoticers = UserNoticerService().generateList(
            data: snapshot.data,
          );
        }
        return Scaffold(
          backgroundColor: kWhiteColor,
          appBar: AppBar(
            backgroundColor: kWhiteColor,
            leading: IconButton(
              icon: const FaIcon(FontAwesomeIcons.chevronLeft),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              '受信者一覧 (${userNoticers.length})',
              style: TextStyle(color: kBlackColor),
            ),
          ),
          body: SafeArea(
            child: userNoticers.isNotEmpty
                ? ListView.builder(
                    itemCount: userNoticers.length,
                    itemBuilder: (context, index) {
                      UserNoticerModel userNoticer = userNoticers[index];
                      return UserNoticerList(
                        userNoticer: userNoticer,
                        onTap: () {
                          Navigator.push(
                            context,
                            PageTransition(
                              type: PageTransitionType.rightToLeft,
                              child: SendSettingUserDetailScreen(
                                userProvider: widget.userProvider,
                                userNoticer: userNoticer,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  )
                : Center(
                    child: Text(
                      '受信者はいません',
                      style: TextStyle(
                        color: kBlackColor.withOpacity(0.5),
                        fontSize: 20,
                      ),
                    ),
                  ),
          ),
        );
      },
    );
  }
}
