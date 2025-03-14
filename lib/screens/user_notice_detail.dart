import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:simple_alert_app/common/style.dart';

class UserNoticeDetailScreen extends StatelessWidget {
  const UserNoticeDetailScreen({super.key});

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
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '受信日時: 2025/03/25 12:59',
                        style: TextStyle(
                          color: kBlackColor.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        '送信者名: 山田太郎',
                        style: TextStyle(
                          color: kBlackColor.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Divider(height: 0, color: kBlackColor.withOpacity(0.5)),
                const SizedBox(height: 8),
                Text(
                  '休業のお知らせ',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'SourceHanSansJP-Bold',
                  ),
                ),
                const SizedBox(height: 8),
                Text('''
平素よりご愛顧いただき、誠にありがとうございます。
このたび、以下の通り休業（または営業時間変更）させていただくこととなりましたので、ご案内申し上げます。

【休業期間（または営業時間変更）】
●○年○月○日（○）〜○月○日（○）

休業期間中、皆様にはご不便をおかけしますが、何卒ご理解賜りますようお願い申し上げます。
今後とも変わらぬご愛顧をよろしくお願い申し上げます。

――――――――――――――――
会社名：〇〇株式会社
担当部署：〇〇課
電話番号：〇〇-〇〇〇〇-〇〇〇〇
メール：〇〇〇@〇〇〇.com
――――――――――――――――



平素よりご愛顧いただき、誠にありがとうございます。
このたび、以下の通り休業（または営業時間変更）させていただくこととなりましたので、ご案内申し上げます。

【休業期間（または営業時間変更）】
●○年○月○日（○）〜○月○日（○）

休業期間中、皆様にはご不便をおかけしますが、何卒ご理解賜りますようお願い申し上げます。
今後とも変わらぬご愛顧をよろしくお願い申し上げます。

――――――――――――――――
会社名：〇〇株式会社
担当部署：〇〇課
電話番号：〇〇-〇〇〇〇-〇〇〇〇
メール：〇〇〇@〇〇〇.com
――――――――――――――――
              '''),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
