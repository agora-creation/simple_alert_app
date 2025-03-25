import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:simple_alert_app/common/functions.dart';
import 'package:simple_alert_app/common/style.dart';
import 'package:simple_alert_app/models/user.dart';
import 'package:simple_alert_app/providers/user.dart';
import 'package:simple_alert_app/widgets/subscription_radio_list.dart';

class UserSubscriptionScreen extends StatefulWidget {
  final UserProvider userProvider;

  const UserSubscriptionScreen({
    required this.userProvider,
    super.key,
  });

  @override
  State<UserSubscriptionScreen> createState() => _UserSubscriptionScreenState();
}

class _UserSubscriptionScreenState extends State<UserSubscriptionScreen> {
  int subscription = 0;

  @override
  void initState() {
    UserModel user = widget.userProvider.user!;
    subscription = user.subscription;
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
          'ご利用中のプラン',
          style: TextStyle(color: kBlackColor),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 16),
        children: [
          SubscriptionRadioList(
            label: 'フリープラン',
            annotation: '※広告表示あり\n※送信先を5人まで登録可能',
            value: 0,
            groupValue: subscription,
            onChanged: (value) async {
              if (value == null) return;
              String? error = await widget.userProvider.updateSubscription(
                subscription: value,
              );
              if (error != null) {
                if (!mounted) return;
                showMessage(context, error, false);
                return;
              }
              await widget.userProvider.reload();
              if (!mounted) return;
              Navigator.pop(context);
            },
          ),
          SubscriptionRadioList(
            label: 'スタンダードプラン',
            annotation: '※広告表示なし\n※送信先を100人まで登録可能',
            value: 1,
            groupValue: subscription,
            onChanged: (value) async {
              if (value == null) return;
              String? error = await widget.userProvider.updateSubscription(
                subscription: value,
              );
              if (error != null) {
                if (!mounted) return;
                showMessage(context, error, false);
                return;
              }
              await widget.userProvider.reload();
              if (!mounted) return;
              Navigator.pop(context);
            },
          ),
          SubscriptionRadioList(
            label: 'プロプラン',
            annotation: '※広告表示なし\n※送信先を500人まで登録可能',
            value: 2,
            groupValue: subscription,
            onChanged: (value) async {
              if (value == null) return;
              String? error = await widget.userProvider.updateSubscription(
                subscription: value,
              );
              if (error != null) {
                if (!mounted) return;
                showMessage(context, error, false);
                return;
              }
              await widget.userProvider.reload();
              if (!mounted) return;
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
