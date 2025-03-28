import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:simple_alert_app/common/functions.dart';
import 'package:simple_alert_app/common/style.dart';
import 'package:simple_alert_app/models/map_user.dart';
import 'package:simple_alert_app/models/user.dart';
import 'package:simple_alert_app/models/user_send.dart';
import 'package:simple_alert_app/providers/user.dart';
import 'package:simple_alert_app/widgets/custom_check_list.dart';

class SendConfScreen extends StatefulWidget {
  final UserProvider userProvider;
  final UserSendModel? userSend;
  final String title;
  final String content;

  const SendConfScreen({
    required this.userProvider,
    this.userSend,
    required this.title,
    required this.content,
    super.key,
  });

  @override
  State<SendConfScreen> createState() => _SendConfScreenState();
}

class _SendConfScreenState extends State<SendConfScreen> {
  List<MapUserModel> sendMapUsers = [];
  List<MapUserModel> selectedSendMapUsers = [];

  @override
  void initState() {
    //プランにより送信先を削除

    UserModel user = widget.userProvider.user!;
    sendMapUsers = user.sendMapUsers;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kWhiteColor,
      appBar: AppBar(
        backgroundColor: kWhiteColor,
        leading: IconButton(
          icon: const FaIcon(FontAwesomeIcons.chevronLeft),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '送信先の選択',
          style: TextStyle(color: kBlackColor),
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (selectedSendMapUsers.isEmpty) {
                selectedSendMapUsers = sendMapUsers;
              } else {
                selectedSendMapUsers = [];
              }
              setState(() {});
            },
            child: Text(
              '全選択',
              style: TextStyle(color: kBlueColor),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: sendMapUsers.isNotEmpty
            ? ListView.builder(
                itemCount: sendMapUsers.length,
                itemBuilder: (context, index) {
                  MapUserModel mapUser = sendMapUsers[index];
                  bool value = selectedSendMapUsers.contains(mapUser);
                  return CustomCheckList(
                    label: mapUser.name,
                    subtitle: Text(
                      mapUser.tel,
                      style: TextStyle(fontSize: 14),
                    ),
                    value: value,
                    onChanged: (value) {
                      if (!selectedSendMapUsers.contains(mapUser)) {
                        selectedSendMapUsers.add(mapUser);
                      } else {
                        selectedSendMapUsers.remove(mapUser);
                      }
                      setState(() {});
                    },
                    activeColor: kBlueColor,
                  );
                },
              )
            : Center(child: Text('送信先はありません')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          String? error = await widget.userProvider.send(
            userSend: widget.userSend,
            title: widget.title,
            content: widget.content,
            selectedSendMapUsers: selectedSendMapUsers,
          );
          if (error != null) {
            if (!mounted) return;
            showMessage(context, error, false);
            return;
          }
          //レビューの促し
          await requestReview();
          if (!mounted) return;
          Navigator.pop(context);
          Navigator.pop(context);
        },
        icon: const FaIcon(
          FontAwesomeIcons.paperPlane,
          color: kWhiteColor,
        ),
        label: Text(
          '送信する',
          style: TextStyle(color: kWhiteColor),
        ),
      ),
    );
  }
}
