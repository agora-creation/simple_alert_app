import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:simple_alert_app/common/functions.dart';
import 'package:simple_alert_app/common/style.dart';
import 'package:simple_alert_app/models/user.dart';
import 'package:simple_alert_app/models/user_noticer.dart';
import 'package:simple_alert_app/models/user_noticer_group.dart';
import 'package:simple_alert_app/providers/user.dart';
import 'package:simple_alert_app/services/user_noticer.dart';
import 'package:simple_alert_app/widgets/custom_alert_dialog.dart';
import 'package:simple_alert_app/widgets/custom_button.dart';
import 'package:simple_alert_app/widgets/custom_check_list.dart';
import 'package:simple_alert_app/widgets/custom_text_form_field.dart';

class SendSettingGroupDetailScreen extends StatefulWidget {
  final UserProvider userProvider;
  final UserNoticerGroupModel userNoticerGroup;

  const SendSettingGroupDetailScreen({
    required this.userProvider,
    required this.userNoticerGroup,
    super.key,
  });

  @override
  State<SendSettingGroupDetailScreen> createState() =>
      _SendSettingGroupDetailScreenState();
}

class _SendSettingGroupDetailScreenState
    extends State<SendSettingGroupDetailScreen> {
  TextEditingController nameController = TextEditingController();
  List<String> selectedUserIds = [];

  @override
  void initState() {
    nameController.text = widget.userNoticerGroup.name;
    selectedUserIds = widget.userNoticerGroup.userIds;
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
          '${widget.userNoticerGroup.name} (${widget.userNoticerGroup.userIds.length})',
          style: TextStyle(color: kBlackColor),
        ),
        actions: [
          TextButton(
            onPressed: () => showDialog(
              context: context,
              builder: (context) => DelDialog(
                userProvider: widget.userProvider,
                userNoticerGroup: widget.userNoticerGroup,
              ),
            ),
            child: Text(
              '削除',
              style: TextStyle(color: kRedColor),
            ),
          ),
          TextButton(
            onPressed: () async {
              String? error = await widget.userProvider.updateUserNoticerGroup(
                userNoticerGroup: widget.userNoticerGroup,
                name: nameController.text,
                userIds: selectedUserIds,
              );
              if (error != null) {
                if (!mounted) return;
                showMessage(context, error, false);
                return;
              }
              if (!mounted) return;
              Navigator.pop(context);
            },
            child: Text(
              '保存',
              style: TextStyle(color: kBlueColor),
            ),
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        behavior: HitTestBehavior.opaque,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                CustomTextFormField(
                  controller: nameController,
                  textInputType: TextInputType.name,
                  maxLines: 1,
                  label: 'グループ名',
                  color: kBlackColor,
                  prefix: Icons.account_box,
                  fillColor: kBlackColor.withOpacity(0.1),
                ),
                const SizedBox(height: 16),
                Text(
                  'グループに所属させる受信者を選択してください。',
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 4),
                Divider(color: kBlackColor.withOpacity(0.5), height: 1),
                StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: UserNoticerService().streamList(
                    userId: user?.id ?? 'error',
                  ),
                  builder: (context, snapshot) {
                    List<UserNoticerModel> userNoticers = [];
                    if (snapshot.hasData) {
                      userNoticers = UserNoticerService().generateList(
                        data: snapshot.data,
                      );
                    }
                    return Expanded(
                      child: userNoticers.isNotEmpty
                          ? ListView.builder(
                              itemCount: userNoticers.length,
                              itemBuilder: (context, index) {
                                UserNoticerModel userNoticer =
                                    userNoticers[index];
                                bool contains = selectedUserIds.contains(
                                  userNoticer.noticerUserId,
                                );
                                return CustomCheckList(
                                  label: userNoticer.noticerUserName,
                                  value: contains,
                                  onChanged: (value) {
                                    if (contains) {
                                      selectedUserIds.remove(
                                        userNoticer.noticerUserId,
                                      );
                                    } else {
                                      selectedUserIds.add(
                                        userNoticer.noticerUserId,
                                      );
                                    }
                                    setState(() {});
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
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DelDialog extends StatelessWidget {
  final UserProvider userProvider;
  final UserNoticerGroupModel userNoticerGroup;

  const DelDialog({
    required this.userProvider,
    required this.userNoticerGroup,
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
            String? error = await userProvider.removeUserNoticerGroup(
              userNoticerGroup: userNoticerGroup,
            );
            if (error != null) {
              showMessage(context, error, false);
              return;
            }
            Navigator.pop(context);
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}
