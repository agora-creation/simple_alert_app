import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:page_transition/page_transition.dart';
import 'package:simple_alert_app/common/style.dart';
import 'package:simple_alert_app/models/user.dart';
import 'package:simple_alert_app/models/user_sender.dart';
import 'package:simple_alert_app/providers/user.dart';
import 'package:simple_alert_app/screens/notice_user_add.dart';
import 'package:simple_alert_app/screens/notice_user_detail.dart';
import 'package:simple_alert_app/services/user_sender.dart';
import 'package:simple_alert_app/widgets/user_sender_list.dart';

class NoticeUserScreen extends StatefulWidget {
  final UserProvider userProvider;

  const NoticeUserScreen({
    required this.userProvider,
    super.key,
  });

  @override
  State<NoticeUserScreen> createState() => _NoticeUserScreenState();
}

class _NoticeUserScreenState extends State<NoticeUserScreen> {
  @override
  Widget build(BuildContext context) {
    UserModel? user = widget.userProvider.user;
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: UserSenderService().streamList(userId: user?.id ?? 'error'),
      builder: (context, snapshot) {
        List<UserSenderModel> userSenders = [];
        if (snapshot.hasData) {
          userSenders = UserSenderService().generateList(
            data: snapshot.data,
          );
        }
        return Scaffold(
          backgroundColor: kWhiteColor,
          appBar: AppBar(
            backgroundColor: kWhiteColor,
            automaticallyImplyLeading: false,
            title: Text(
              '受信先一覧 (${userSenders.length})',
              style: TextStyle(color: kBlackColor),
            ),
            actions: [
              IconButton(
                icon: const FaIcon(FontAwesomeIcons.xmark),
                onPressed: () =>
                    Navigator.of(context, rootNavigator: true).pop(),
              ),
            ],
          ),
          body: SafeArea(
            child: userSenders.isNotEmpty
                ? ListView.builder(
                    itemCount: userSenders.length,
                    itemBuilder: (context, index) {
                      UserSenderModel userSender = userSenders[index];
                      return UserSenderList(
                        userSender: userSender,
                        onTap: () {
                          Navigator.push(
                            context,
                            PageTransition(
                              type: PageTransitionType.rightToLeft,
                              child: NoticeUserDetailScreen(
                                userProvider: widget.userProvider,
                                userSender: userSender,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  )
                : Center(
                    child: Text(
                      '受信先を追加してください',
                      style: TextStyle(
                        color: kBlackColor.withOpacity(0.5),
                        fontSize: 20,
                      ),
                    ),
                  ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              Navigator.push(
                context,
                PageTransition(
                  type: PageTransitionType.rightToLeft,
                  child: NoticeUserAddScreen(
                    userProvider: widget.userProvider,
                  ),
                ),
              );
            },
            icon: const FaIcon(
              FontAwesomeIcons.qrcode,
              size: 18,
              color: kWhiteColor,
            ),
            label: Text(
              '受信先を追加(QR)',
              style: TextStyle(color: kWhiteColor),
            ),
          ),
        );
      },
    );
  }
}
