import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:simple_alert_app/common/functions.dart';
import 'package:simple_alert_app/common/style.dart';
import 'package:simple_alert_app/widgets/info_list.dart';
import 'package:url_launcher/url_launcher.dart';

class InfoScreen extends StatelessWidget {
  const InfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kWhiteColor,
      appBar: AppBar(
        backgroundColor: kWhiteColor,
        automaticallyImplyLeading: false,
        title: const Text(
          'アプリ情報',
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
        child: Column(
          children: [
            InfoList(
              label: '利用規約',
              trailing: const FaIcon(
                FontAwesomeIcons.chevronRight,
                size: 16,
              ),
              onTap: () async {
                if (!await launchUrl(Uri.parse(
                  'https://docs.google.com/document/d/18yzTySjHTdCE_VHS6NjAeP8OfTpfqyh5VZjaqBgdP78/edit?usp=sharing',
                ))) {
                  throw Exception('Could not launch');
                }
              },
            ),
            InfoList(
              label: 'プライバシーポリシー',
              trailing: const FaIcon(
                FontAwesomeIcons.chevronRight,
                size: 16,
              ),
              onTap: () async {
                if (!await launchUrl(Uri.parse(
                  'https://docs.google.com/document/d/1HIbeGeI1HEl1JnVBTiFjrJk0JZeUWSehahu4WfApWR4/edit?usp=sharing',
                ))) {
                  throw Exception('Could not launch');
                }
              },
            ),
            InfoList(
              label: 'アプリについての意見・要望',
              trailing: const FaIcon(
                FontAwesomeIcons.chevronRight,
                size: 16,
              ),
              onTap: () async {
                if (!await launchUrl(Uri.parse(
                  'https://docs.google.com/forms/d/e/1FAIpQLSdWK2o3g03yquFPKnv-eBZy78_tShlYFZYMe_WAvgON7b3YUg/viewform?usp=sharing',
                ))) {
                  throw Exception('Could not launch');
                }
              },
            ),
            InfoList(
              label: 'アプリのバージョン',
              trailing: FutureBuilder<String>(
                future: getVersionInfo(),
                builder: (context, snapshot) {
                  return Text(
                    snapshot.data ?? '',
                    style: TextStyle(fontSize: 14),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
