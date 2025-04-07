import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:page_transition/page_transition.dart';
import 'package:simple_alert_app/common/functions.dart';
import 'package:simple_alert_app/common/style.dart';
import 'package:simple_alert_app/models/map_user.dart';
import 'package:simple_alert_app/models/user.dart';
import 'package:simple_alert_app/providers/user.dart';
import 'package:simple_alert_app/screens/notice_user_add.dart';
import 'package:simple_alert_app/widgets/custom_alert_dialog.dart';
import 'package:simple_alert_app/widgets/custom_button.dart';
import 'package:simple_alert_app/widgets/custom_check_list.dart';

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
  List<MapUserModel> noticeMapUsers = [];
  List<MapUserModel> selectedNoticeMapUsers = [];

  void _reload(UserModel user) {
    noticeMapUsers = user.noticeMapUsers;
    setState(() {});
  }

  @override
  void initState() {
    UserModel user = widget.userProvider.user!;
    noticeMapUsers = user.noticeMapUsers;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kWhiteColor,
      appBar: AppBar(
        backgroundColor: kWhiteColor,
        automaticallyImplyLeading: false,
        title: const Text(
          '受信先一覧',
          style: TextStyle(color: kBlackColor),
        ),
        actions: [
          selectedNoticeMapUsers.isNotEmpty
              ? TextButton(
                  onPressed: () => showDialog(
                    context: context,
                    builder: (context) => DelDialog(
                      userProvider: widget.userProvider,
                      selectedNoticeMapUsers: selectedNoticeMapUsers,
                      reload: _reload,
                    ),
                  ),
                  child: Text(
                    '選択項目を削除',
                    style: TextStyle(color: kRedColor),
                  ),
                )
              : Container(),
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.xmark),
            onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
          ),
        ],
      ),
      body: SafeArea(
        child: noticeMapUsers.isNotEmpty
            ? ListView.builder(
                itemCount: noticeMapUsers.length,
                itemBuilder: (context, index) {
                  MapUserModel mapUser = noticeMapUsers[index];
                  bool value = selectedNoticeMapUsers.contains(mapUser);
                  return CustomCheckList(
                    label: mapUser.name,
                    subtitle: Text(
                      mapUser.tel,
                      style: TextStyle(fontSize: 14),
                    ),
                    value: value,
                    onChanged: (value) {
                      if (!selectedNoticeMapUsers.contains(mapUser)) {
                        selectedNoticeMapUsers.add(mapUser);
                      } else {
                        selectedNoticeMapUsers.remove(mapUser);
                      }
                      setState(() {});
                    },
                    activeColor: kRedColor,
                  );
                },
              )
            : Center(child: Text('受信先はありません')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            PageTransition(
              type: PageTransitionType.rightToLeft,
              child: NoticeUserAddScreen(
                userProvider: widget.userProvider,
                reload: _reload,
              ),
            ),
          );
        },
        icon: const FaIcon(
          FontAwesomeIcons.plus,
          color: kWhiteColor,
        ),
        label: Text(
          '受信先を登録',
          style: TextStyle(color: kWhiteColor),
        ),
      ),
    );
  }
}

class DelDialog extends StatelessWidget {
  final UserProvider userProvider;
  final List<MapUserModel> selectedNoticeMapUsers;
  final Function(UserModel) reload;

  const DelDialog({
    required this.userProvider,
    required this.selectedNoticeMapUsers,
    required this.reload,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return CustomAlertDialog(
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 8),
          Text(
            '本当に削除しますか？',
            style: TextStyle(color: kRedColor),
          ),
        ],
      ),
      actions: [
        CustomButton(
          type: ButtonSizeType.sm,
          label: 'キャンセル',
          labelColor: kWhiteColor,
          backgroundColor: kBlackColor.withOpacity(0.5),
          onPressed: () => Navigator.pop(context),
        ),
        CustomButton(
          type: ButtonSizeType.sm,
          label: '削除する',
          labelColor: kWhiteColor,
          backgroundColor: kRedColor,
          onPressed: () async {
            String? error = await userProvider.removeNoticeMapUsers(
              selectedNoticeMapUsers: selectedNoticeMapUsers,
            );
            if (error != null) {
              showMessage(context, error, false);
              return;
            }
            await userProvider.reload();
            reload(userProvider.user!);
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}
