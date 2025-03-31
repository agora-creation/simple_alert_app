import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:simple_alert_app/common/functions.dart';
import 'package:simple_alert_app/common/style.dart';
import 'package:simple_alert_app/models/map_user.dart';
import 'package:simple_alert_app/models/user.dart';
import 'package:simple_alert_app/providers/user.dart';
import 'package:simple_alert_app/widgets/alert_bar.dart';
import 'package:simple_alert_app/widgets/custom_alert_dialog.dart';
import 'package:simple_alert_app/widgets/custom_button.dart';
import 'package:simple_alert_app/widgets/custom_check_list.dart';

class SendUserScreen extends StatefulWidget {
  final UserProvider userProvider;

  const SendUserScreen({
    required this.userProvider,
    super.key,
  });

  @override
  State<SendUserScreen> createState() => _SendUserScreenState();
}

class _SendUserScreenState extends State<SendUserScreen> {
  List<MapUserModel> sendMapUsers = [];
  List<MapUserModel> selectedSendMapUsers = [];

  void _reload(UserModel user) {
    sendMapUsers = user.sendMapUsers;
    setState(() {});
  }

  @override
  void initState() {
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
          '送信先一覧',
          style: TextStyle(color: kBlackColor),
        ),
        actions: [
          selectedSendMapUsers.isNotEmpty
              ? TextButton(
                  onPressed: () => showDialog(
                    context: context,
                    builder: (context) => DelDialog(
                      userProvider: widget.userProvider,
                      selectedSendMapUsers: selectedSendMapUsers,
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
        child: Column(
          children: [
            AlertBar(
              '送信先を増やすには、受信者宛に電話番号を伝えてください。受信者はその電話番号を「受信先一覧」で登録すると、こちらにも反映します。',
            ),
            Expanded(
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
                          activeColor: kRedColor,
                        );
                      },
                    )
                  : Center(child: Text('送信先はありません')),
            ),
          ],
        ),
      ),
    );
  }
}

class DelDialog extends StatelessWidget {
  final UserProvider userProvider;
  final List<MapUserModel> selectedSendMapUsers;
  final Function(UserModel) reload;

  const DelDialog({
    required this.userProvider,
    required this.selectedSendMapUsers,
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
            String? error = await userProvider.removeSendMapUsers(
              selectedSendMapUsers: selectedSendMapUsers,
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
