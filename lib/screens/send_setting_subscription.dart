import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:simple_alert_app/common/style.dart';
import 'package:simple_alert_app/providers/user.dart';

class SendSettingSubscriptionScreen extends StatefulWidget {
  final UserProvider userProvider;

  const SendSettingSubscriptionScreen({
    required this.userProvider,
    super.key,
  });

  @override
  State<SendSettingSubscriptionScreen> createState() =>
      _SendSettingSubscriptionScreenState();
}

class _SendSettingSubscriptionScreenState
    extends State<SendSettingSubscriptionScreen> {
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
          'ご利用中のプラン',
          style: TextStyle(color: kBlackColor),
        ),
      ),
    );
  }
}
