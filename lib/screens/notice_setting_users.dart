import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:page_transition/page_transition.dart';
import 'package:simple_alert_app/common/functions.dart';
import 'package:simple_alert_app/common/style.dart';
import 'package:simple_alert_app/models/map_user.dart';
import 'package:simple_alert_app/models/user.dart';
import 'package:simple_alert_app/providers/user.dart';
import 'package:simple_alert_app/screens/notice_setting_users_add.dart';
import 'package:simple_alert_app/widgets/custom_alert_dialog.dart';
import 'package:simple_alert_app/widgets/custom_button.dart';
import 'package:simple_alert_app/widgets/custom_check_list.dart';

class NoticeSettingUsersScreen extends StatefulWidget {
  final UserProvider userProvider;

  const NoticeSettingUsersScreen({
    required this.userProvider,
    super.key,
  });

  @override
  State<NoticeSettingUsersScreen> createState() =>
      _NoticeSettingUsersScreenState();
}

class _NoticeSettingUsersScreenState extends State<NoticeSettingUsersScreen> {
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
    UserModel? user = widget.userProvider.user;
    return Scaffold(
      backgroundColor: kWhiteColor,
      appBar: AppBar(
        backgroundColor: kWhiteColor,
        leading: IconButton(
          icon: const FaIcon(FontAwesomeIcons.chevronLeft),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '受信先一覧 (${user?.noticeMapUsers.length})',
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
            : Center(
                child: Container(
                  color: kRedColor,
                  padding: EdgeInsets.all(8),
                  child: Text(
                    '受信先を追加してください',
                    style: TextStyle(
                      color: kWhiteColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'SourceHanSansJP-Bold',
                    ),
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
              child: NoticeSettingUsersAddScreen(
                userProvider: widget.userProvider,
                reload: _reload,
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
          '受信先を追加',
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
