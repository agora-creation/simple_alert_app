import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:page_transition/page_transition.dart';
import 'package:simple_alert_app/common/functions.dart';
import 'package:simple_alert_app/common/style.dart';
import 'package:simple_alert_app/models/user_send.dart';
import 'package:simple_alert_app/providers/user.dart';
import 'package:simple_alert_app/screens/send_create2.dart';
import 'package:simple_alert_app/widgets/custom_alert_dialog.dart';
import 'package:simple_alert_app/widgets/custom_button.dart';
import 'package:simple_alert_app/widgets/custom_text_form_field.dart';

class SendCreateScreen extends StatefulWidget {
  final UserProvider userProvider;
  final UserSendModel? userSend;

  const SendCreateScreen({
    required this.userProvider,
    this.userSend,
    super.key,
  });

  @override
  State<SendCreateScreen> createState() => _SendCreateScreenState();
}

class _SendCreateScreenState extends State<SendCreateScreen> {
  TextEditingController titleController = TextEditingController();
  TextEditingController contentController = TextEditingController();
  bool isChoice = false;
  List<String> choices = [];
  List<TextEditingController> choiceControllers = [];

  void updateChoices() {
    choices = choiceControllers.map((controller) => controller.text).toList();
    setState(() {});
  }

  void addChoices() {
    choices.add('新しい選択肢');
    choiceControllers.add(TextEditingController(text: '新しい選択肢'));
    setState(() {});
  }

  void removeChoices(int index) {
    choices.removeAt(index);
    choiceControllers[index].dispose();
    choiceControllers.removeAt(index);
    setState(() {});
  }

  @override
  void initState() {
    if (widget.userSend != null) {
      titleController.text = widget.userSend!.title;
      contentController.text = widget.userSend!.content;
    }
    if (kDefaultChoices.isNotEmpty) {
      for (final choice in kDefaultChoices) {
        choices.add(choice);
      }
    }
    choiceControllers =
        choices.map((choice) => TextEditingController(text: choice)).toList();
    super.initState();
  }

  @override
  void dispose() {
    for (final controller in choiceControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kWhiteColor,
      appBar: AppBar(
        backgroundColor: kWhiteColor,
        automaticallyImplyLeading: false,
        actions: [
          widget.userSend != null
              ? TextButton(
                  onPressed: () => showDialog(
                    context: context,
                    builder: (context) => DelDialog(
                      userProvider: widget.userProvider,
                      userSend: widget.userSend!,
                    ),
                  ),
                  child: Text(
                    '削除',
                    style: TextStyle(color: kRedColor),
                  ),
                )
              : Container(),
          widget.userSend != null
              ? TextButton(
                  onPressed: () async {
                    if (titleController.text == '') {
                      if (!mounted) return;
                      showMessage(context, '件名を入力してください', false);
                      return;
                    }
                    String? error = await widget.userProvider.updateSendDraft(
                      userSend: widget.userSend!,
                      title: titleController.text,
                      content: contentController.text,
                      isChoice: isChoice,
                      choices: choices,
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
                )
              : Container(),
          widget.userSend == null
              ? TextButton(
                  onPressed: () async {
                    if (titleController.text == '') {
                      if (!mounted) return;
                      showMessage(context, '件名を入力してください', false);
                      return;
                    }
                    String? error = await widget.userProvider.createSendDraft(
                      title: titleController.text,
                      content: contentController.text,
                      isChoice: isChoice,
                      choices: choices,
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
                    '下書き保存',
                    style: TextStyle(color: kBlueColor),
                  ),
                )
              : Container(),
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.xmark),
            onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        behavior: HitTestBehavior.opaque,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  CustomTextFormField(
                    controller: titleController,
                    textInputType: TextInputType.text,
                    maxLines: 1,
                    label: '件名',
                    color: kBlackColor,
                    prefix: Icons.short_text,
                    fillColor: kBlackColor.withOpacity(0.1),
                  ),
                  const SizedBox(height: 8),
                  CustomTextFormField(
                    controller: contentController,
                    textInputType: TextInputType.multiline,
                    maxLines: 15,
                    label: '内容',
                    color: kBlackColor,
                    prefix: Icons.wrap_text,
                    fillColor: kBlackColor.withOpacity(0.1),
                  ),
                  const SizedBox(height: 8),
                  Column(
                    children: [
                      Divider(color: kBlackColor.withOpacity(0.5), height: 1),
                      CheckboxListTile(
                        title: Text('回答を求める'),
                        value: isChoice,
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() {
                            isChoice = value;
                          });
                        },
                        tileColor:
                            isChoice ? kRedColor.withOpacity(0.3) : kWhiteColor,
                        activeColor: kRedColor,
                      ),
                      Divider(color: kBlackColor.withOpacity(0.5), height: 1),
                    ],
                  ),
                  Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: kBlackColor.withOpacity(0.5),
                        ),
                      ),
                    ),
                    child: ExpansionTile(
                      enabled: isChoice,
                      title: Text('選択肢を設定'),
                      children: [
                        ListView.builder(
                          shrinkWrap: true,
                          itemCount: choices.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: choiceControllers[index],
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(),
                                      ),
                                      onChanged: (value) {
                                        updateChoices();
                                      },
                                    ),
                                  ),
                                  IconButton(
                                    icon: FaIcon(
                                      FontAwesomeIcons.xmark,
                                      color: kRedColor,
                                    ),
                                    onPressed: () => removeChoices(index),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: CustomButton(
                            type: ButtonSizeType.sm,
                            label: '選択肢を追加',
                            labelColor: kWhiteColor,
                            backgroundColor: kBlueColor,
                            onPressed: addChoices,
                          ),
                        ),
                        SizedBox(height: 8),
                      ],
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (titleController.text == '') {
            if (!mounted) return;
            showMessage(context, '件名を入力してください', false);
            return;
          }
          if (contentController.text == '') {
            if (!mounted) return;
            showMessage(context, '内容を入力してください', false);
            return;
          }
          Navigator.push(
            context,
            PageTransition(
              type: PageTransitionType.rightToLeft,
              child: SendCreate2Screen(
                userProvider: widget.userProvider,
                userSend: widget.userSend,
                title: titleController.text,
                content: contentController.text,
                isChoice: isChoice,
                choices: choices,
              ),
            ),
          );
        },
        icon: const FaIcon(
          FontAwesomeIcons.listCheck,
          size: 18,
          color: kWhiteColor,
        ),
        label: Text(
          '送信先の選択',
          style: TextStyle(color: kWhiteColor),
        ),
      ),
    );
  }
}

class DelDialog extends StatefulWidget {
  final UserProvider userProvider;
  final UserSendModel userSend;

  const DelDialog({
    required this.userProvider,
    required this.userSend,
    super.key,
  });

  @override
  State<DelDialog> createState() => _DelDialogState();
}

class _DelDialogState extends State<DelDialog> {
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
            String? error = await widget.userProvider.deleteSendDraft(
              userSend: widget.userSend,
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
        ),
      ],
    );
  }
}
