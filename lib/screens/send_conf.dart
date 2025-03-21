import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:simple_alert_app/common/functions.dart';
import 'package:simple_alert_app/common/style.dart';
import 'package:simple_alert_app/models/map_send_user.dart';
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
  List<MapSendUserModel> mapSendUsers = [];
  List<MapSendUserModel> sendMapSendUsers = [];

  @override
  void initState() {
    UserModel user = widget.userProvider.user!;
    mapSendUsers = user.mapSendUsers;
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
          '送信先の確認',
          style: TextStyle(color: kBlackColor),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  color: kBlackColor.withOpacity(0.1),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'SourceHanSansJP-Bold',
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(widget.content),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '送信先一覧',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'SourceHanSansJP-Bold',
                  ),
                ),
                mapSendUsers.isNotEmpty
                    ? ListView.builder(
                        shrinkWrap: true,
                        itemCount: mapSendUsers.length,
                        itemBuilder: (context, index) {
                          MapSendUserModel mapSendUser = mapSendUsers[index];
                          bool value = sendMapSendUsers.contains(mapSendUser);
                          return CustomCheckList(
                            label: mapSendUser.name,
                            subtitle: Text(
                              mapSendUser.email,
                              style: TextStyle(fontSize: 14),
                            ),
                            value: value,
                            onChanged: (value) {
                              if (!sendMapSendUsers.contains(mapSendUser)) {
                                sendMapSendUsers.add(mapSendUser);
                              } else {
                                sendMapSendUsers.remove(mapSendUser);
                              }
                              setState(() {});
                            },
                            activeColor: kBlueColor,
                          );
                        },
                      )
                    : Text('送信先はありません'),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          String? error = await widget.userProvider.send(
            userSend: widget.userSend,
            title: widget.title,
            content: widget.content,
            sendMapSendUsers: sendMapSendUsers,
          );
          if (error != null) {
            if (!mounted) return;
            showMessage(context, error, false);
            return;
          }
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
