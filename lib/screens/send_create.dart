import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:page_transition/page_transition.dart';
import 'package:simple_alert_app/common/functions.dart';
import 'package:simple_alert_app/common/style.dart';
import 'package:simple_alert_app/models/user_send.dart';
import 'package:simple_alert_app/providers/user.dart';
import 'package:simple_alert_app/screens/send_conf.dart';
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

  @override
  void initState() {
    if (widget.userSend != null) {
      titleController.text = widget.userSend!.title;
      contentController.text = widget.userSend!.content;
    }
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
          '新規送信',
          style: TextStyle(color: kBlackColor),
        ),
        actions: [
          widget.userSend != null
              ? TextButton(
                  onPressed: () async {
                    String? error = await widget.userProvider.deleteSendDraft(
                      userSend: widget.userSend!,
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
                    '削除',
                    style: TextStyle(color: kRedColor),
                  ),
                )
              : Container(),
          widget.userSend != null
              ? TextButton(
                  onPressed: () async {
                    String? error = await widget.userProvider.updateSendDraft(
                      userSend: widget.userSend!,
                      title: titleController.text,
                      content: contentController.text,
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
                    String? error = await widget.userProvider.createSendDraft(
                      title: titleController.text,
                      content: contentController.text,
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
                  ),
                  const SizedBox(height: 8),
                  CustomTextFormField(
                    controller: contentController,
                    textInputType: TextInputType.multiline,
                    maxLines: 20,
                    label: '内容',
                    color: kBlackColor,
                    prefix: Icons.wrap_text,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: widget.userProvider.user!.sendMapUsers.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  PageTransition(
                    type: PageTransitionType.rightToLeft,
                    child: SendConfScreen(
                      userProvider: widget.userProvider,
                      userSend: widget.userSend,
                      title: titleController.text,
                      content: contentController.text,
                    ),
                  ),
                );
              },
              icon: const FaIcon(
                FontAwesomeIcons.paperPlane,
                color: kWhiteColor,
              ),
              label: Text(
                '送信先の確認',
                style: TextStyle(color: kWhiteColor),
              ),
            )
          : null,
    );
  }
}
