import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:form_builder_file_picker/form_builder_file_picker.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:simple_alert_app/common/functions.dart';
import 'package:simple_alert_app/common/style.dart';
import 'package:simple_alert_app/models/send_user.dart';
import 'package:simple_alert_app/models/user.dart';
import 'package:simple_alert_app/models/user_noticer.dart';
import 'package:simple_alert_app/models/user_noticer_group.dart';
import 'package:simple_alert_app/models/user_send.dart';
import 'package:simple_alert_app/providers/user.dart';
import 'package:simple_alert_app/services/purchases.dart';
import 'package:simple_alert_app/services/user_noticer.dart';
import 'package:simple_alert_app/services/user_noticer_group.dart';
import 'package:simple_alert_app/services/user_send.dart';
import 'package:simple_alert_app/widgets/alert_bar.dart';
import 'package:simple_alert_app/widgets/custom_alert_dialog.dart';
import 'package:simple_alert_app/widgets/custom_button.dart';
import 'package:simple_alert_app/widgets/custom_check_list.dart';

class SendCreate2Screen extends StatefulWidget {
  final UserProvider userProvider;
  final UserSendModel? userSend;
  final String title;
  final String content;
  final bool isChoice;
  final List<String> choices;
  final PlatformFile? pickedFile;

  const SendCreate2Screen({
    required this.userProvider,
    this.userSend,
    required this.title,
    required this.content,
    required this.isChoice,
    required this.choices,
    required this.pickedFile,
    super.key,
  });

  @override
  State<SendCreate2Screen> createState() => _SendCreate2ScreenState();
}

class _SendCreate2ScreenState extends State<SendCreate2Screen> {
  String purchasesId = '';
  int monthSendCount = 0;
  int monthSendLimit = 0;
  List<UserNoticerGroupModel> userNoticerGroups = [];
  String selectedGroupId = '';
  List<SendUserModel> selectedSendUsers = [];

  void _initPurchasesListener() async {
    Purchases.addCustomerInfoUpdateListener((customerInfo) async {
      CustomerInfo customerInfo = await Purchases.getCustomerInfo();
      EntitlementInfo? entitlement =
          customerInfo.entitlements.all['subscription'];
      if (mounted) {
        setState(() {
          purchasesId = entitlement?.productIdentifier ?? '';
        });
      }
    });
  }

  void _init() async {
    monthSendCount = await UserSendService().selectMonthSendCount(
      userId: widget.userProvider.user?.id ?? 'error',
    );
    monthSendLimit = PurchasesService().getMonthSendLimit(purchasesId);
    userNoticerGroups = await UserNoticerGroupService().selectList(
      userId: widget.userProvider.user?.id ?? 'error',
    );
    setState(() {});
  }

  @override
  void initState() {
    _initPurchasesListener();
    _init();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    UserModel? user = widget.userProvider.user;
    int selectedLimit = 0;
    if (monthSendLimit > monthSendCount) {
      selectedLimit = monthSendLimit - monthSendCount;
    }
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: UserNoticerService().streamList(
        userId: user?.id ?? 'error',
      ),
      builder: (context, snapshot) {
        List<UserNoticerModel> userNoticers = [];
        if (snapshot.hasData) {
          userNoticers = UserNoticerService().generateList(
            data: snapshot.data,
            isBlockView: false,
          );
        }
        List<UserNoticerModel> viewUserNoticers = [];
        if (selectedGroupId == '') {
          viewUserNoticers = userNoticers;
        } else {
          UserNoticerGroupModel tmpGroup = userNoticerGroups.firstWhere(
            (e) => e.id == selectedGroupId,
          );
          List<String> tmpUserIds = tmpGroup.userIds;
          for (final userNoticer in userNoticers) {
            if (tmpUserIds.contains(userNoticer.noticerUserId)) {
              viewUserNoticers.add(userNoticer);
            }
          }
        }
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
            actions: [
              TextButton(
                onPressed: () {
                  if (selectedSendUsers.isEmpty) {
                    selectedSendUsers.clear();
                    if (viewUserNoticers.isNotEmpty) {
                      for (final userNoticer in viewUserNoticers) {
                        SendUserModel sendUser = SendUserModel.fromMap({
                          'id': userNoticer.noticerUserId,
                          'name': userNoticer.noticerUserName,
                          'answer': '',
                        });
                        selectedSendUsers.add(sendUser);
                      }
                    }
                  } else {
                    selectedSendUsers.clear();
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
            child: Column(
              children: [
                AlertBar('あと$selectedLimit件まで送信可'),
                DropdownButton(
                  items: [
                    DropdownMenuItem(
                      value: '',
                      child: Text('全ての受信者 (${userNoticers.length})'),
                    ),
                    ...userNoticerGroups.map((userNoticerGroup) {
                      return DropdownMenuItem(
                        value: userNoticerGroup.id,
                        child: Text(
                          '${userNoticerGroup.name} (${userNoticerGroup.userIds.length})',
                        ),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    selectedGroupId = value ?? '';
                    selectedSendUsers.clear();
                    setState(() {});
                  },
                  value: selectedGroupId,
                  isExpanded: true,
                  underline: Container(),
                  padding: EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 16,
                  ),
                ),
                Divider(height: 1),
                Expanded(
                  child: viewUserNoticers.isNotEmpty
                      ? ListView.builder(
                          itemCount: viewUserNoticers.length,
                          itemBuilder: (context, index) {
                            UserNoticerModel userNoticer =
                                viewUserNoticers[index];
                            bool contain = false;
                            if (selectedSendUsers.isNotEmpty) {
                              for (final sendUser in selectedSendUsers) {
                                if (sendUser.id == userNoticer.noticerUserId) {
                                  contain = true;
                                }
                              }
                            }
                            return CustomCheckList(
                              label: userNoticer.noticerUserName,
                              value: contain,
                              onChanged: (value) {
                                if (contain) {
                                  selectedSendUsers.removeWhere(
                                    (e) => e.id == userNoticer.noticerUserId,
                                  );
                                } else {
                                  selectedSendUsers.add(SendUserModel.fromMap({
                                    'id': userNoticer.noticerUserId,
                                    'name': userNoticer.noticerUserName,
                                    'answer': '',
                                  }));
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
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () async {
              if (selectedSendUsers.isEmpty) {
                if (!mounted) return;
                showMessage(context, '送信先を1つ以上選択してください', false);
                return;
              }
              if (selectedSendUsers.length > selectedLimit) {
                if (!mounted) return;
                showMessage(context, '送信制限により送信できません', false);
                return;
              }
              showDialog(
                context: context,
                builder: (context) => SendDialog(
                  userProvider: widget.userProvider,
                  userSend: widget.userSend,
                  title: widget.title,
                  content: widget.content,
                  isChoice: widget.isChoice,
                  choices: widget.choices,
                  pickedFile: widget.pickedFile,
                  selectedSendUsers: selectedSendUsers,
                ),
              );
            },
            icon: const FaIcon(
              FontAwesomeIcons.paperPlane,
              size: 18,
              color: kWhiteColor,
            ),
            label: Text(
              '送信する',
              style: TextStyle(color: kWhiteColor),
            ),
          ),
        );
      },
    );
  }
}

class SendDialog extends StatefulWidget {
  final UserProvider userProvider;
  final UserSendModel? userSend;
  final String title;
  final String content;
  final bool isChoice;
  final List<String> choices;
  final PlatformFile? pickedFile;
  final List<SendUserModel> selectedSendUsers;

  const SendDialog({
    required this.userProvider,
    required this.userSend,
    required this.title,
    required this.content,
    required this.isChoice,
    required this.choices,
    required this.pickedFile,
    required this.selectedSendUsers,
    super.key,
  });

  @override
  State<SendDialog> createState() => _SendDialogState();
}

class _SendDialogState extends State<SendDialog> {
  @override
  Widget build(BuildContext context) {
    return CustomAlertDialog(
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 8),
          Text('本当に送信しますか？'),
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
          label: '送信する',
          labelColor: kWhiteColor,
          backgroundColor: kBlueColor,
          onPressed: () async {
            String? error = await widget.userProvider.send(
              userSend: widget.userSend,
              title: widget.title,
              content: widget.content,
              isChoice: widget.isChoice,
              choices: widget.choices,
              pickedFile: widget.pickedFile,
              selectedSendUsers: widget.selectedSendUsers,
            );
            if (error != null) {
              if (!mounted) return;
              showMessage(context, error, false);
              return;
            }
            //レビューの促し
            //await requestReview();
            if (!mounted) return;
            Navigator.pop(context);
            Navigator.pop(context);
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}
