import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:page_transition/page_transition.dart';
import 'package:simple_alert_app/common/style.dart';
import 'package:simple_alert_app/models/user.dart';
import 'package:simple_alert_app/models/user_noticer_group.dart';
import 'package:simple_alert_app/providers/user.dart';
import 'package:simple_alert_app/screens/send_setting_group_add.dart';
import 'package:simple_alert_app/screens/send_setting_group_detail.dart';
import 'package:simple_alert_app/services/user_noticer_group.dart';
import 'package:simple_alert_app/widgets/user_noticer_group_list.dart';

class SendSettingGroupScreen extends StatefulWidget {
  final UserProvider userProvider;

  const SendSettingGroupScreen({
    required this.userProvider,
    super.key,
  });

  @override
  State<SendSettingGroupScreen> createState() => _SendSettingGroupScreenState();
}

class _SendSettingGroupScreenState extends State<SendSettingGroupScreen> {
  @override
  Widget build(BuildContext context) {
    UserModel? user = widget.userProvider.user;
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: UserNoticerGroupService().streamList(userId: user?.id ?? 'error'),
      builder: (context, snapshot) {
        List<UserNoticerGroupModel> userNoticerGroups = [];
        if (snapshot.hasData) {
          userNoticerGroups = UserNoticerGroupService().generateList(
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
              '受信者をグループ分け (${userNoticerGroups.length})',
              style: TextStyle(color: kBlackColor),
            ),
          ),
          body: SafeArea(
            child: userNoticerGroups.isNotEmpty
                ? ListView.builder(
                    itemCount: userNoticerGroups.length,
                    itemBuilder: (context, index) {
                      UserNoticerGroupModel userNoticerGroup =
                          userNoticerGroups[index];
                      return UserNoticerGroupList(
                        userNoticerGroup: userNoticerGroup,
                        onTap: () {
                          Navigator.push(
                            context,
                            PageTransition(
                              type: PageTransitionType.rightToLeft,
                              child: SendSettingGroupDetailScreen(
                                userProvider: widget.userProvider,
                                userNoticerGroup: userNoticerGroup,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  )
                : Center(
                    child: Text(
                      'グループを追加してください',
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
                  child: SendSettingGroupAddScreen(
                    userProvider: widget.userProvider,
                  ),
                ),
              );
            },
            icon: const FaIcon(
              FontAwesomeIcons.plus,
              size: 18,
              color: kWhiteColor,
            ),
            label: Text(
              'グループを追加',
              style: TextStyle(color: kWhiteColor),
            ),
          ),
        );
      },
    );
  }
}
