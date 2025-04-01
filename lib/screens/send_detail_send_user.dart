import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:simple_alert_app/common/style.dart';
import 'package:simple_alert_app/models/map_user.dart';
import 'package:simple_alert_app/widgets/map_user_list.dart';

class SendDetailSendUserScreen extends StatelessWidget {
  final List<MapUserModel> sendMapUsers;

  const SendDetailSendUserScreen({
    required this.sendMapUsers,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kWhiteColor,
      appBar: AppBar(
        backgroundColor: kWhiteColor,
        automaticallyImplyLeading: false,
        title: const Text(
          '送信先を確認',
          style: TextStyle(color: kBlackColor),
        ),
        actions: [
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.xmark),
            onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView.builder(
          itemCount: sendMapUsers.length,
          itemBuilder: (context, index) {
            MapUserModel mapUser = sendMapUsers[index];
            return MapUserList(mapUser: mapUser);
          },
        ),
      ),
    );
  }
}
