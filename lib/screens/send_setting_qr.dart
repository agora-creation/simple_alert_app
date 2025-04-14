import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:simple_alert_app/common/style.dart';
import 'package:simple_alert_app/providers/user.dart';
import 'package:simple_alert_app/widgets/alert_bar.dart';

class SendSettingQrScreen extends StatelessWidget {
  final UserProvider userProvider;

  const SendSettingQrScreen({
    required this.userProvider,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    String userId = userProvider.user?.id ?? '';
    String qrData = 'AGORA-$userId';
    return Scaffold(
      backgroundColor: kWhiteColor,
      appBar: AppBar(
        backgroundColor: kWhiteColor,
        leading: IconButton(
          icon: const FaIcon(FontAwesomeIcons.chevronLeft),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            AlertBar('受信者に見せてください'),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: PrettyQrView.data(data: qrData),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
