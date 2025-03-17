import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:simple_alert_app/common/style.dart';
import 'package:simple_alert_app/providers/user.dart';
import 'package:simple_alert_app/widgets/custom_button.dart';

class SendScreen extends StatelessWidget {
  const SendScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    bool isSender = userProvider.user?.isSender ?? false;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Card(
          color: kWhiteColor,
          elevation: 0,
          shape: RoundedRectangleBorder(),
          child: isSender
              ? Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('送信履歴一覧'),
                          CustomButton(
                            type: ButtonSizeType.sm,
                            label: '送信する',
                            labelColor: kWhiteColor,
                            backgroundColor: kBlueColor,
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ),
                    Divider(height: 0, color: kBlackColor.withOpacity(0.5)),
                    Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: 100,
                        itemBuilder: (context, index) {
                          bool draft = false;
                          if (index % 5 == 0) {
                            draft = true;
                          }
                          return Container(
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: kBlackColor.withOpacity(0.5),
                                ),
                              ),
                              color: draft
                                  ? kRedColor.withOpacity(0.3)
                                  : kWhiteColor,
                            ),
                            child: ListTile(
                              title: Text('今日の出店のお知らせ'),
                              subtitle: draft
                                  ? null
                                  : Text(
                                      '送信日時: 2023/01/01 10:00',
                                      style: TextStyle(
                                        color: kBlackColor.withOpacity(0.8),
                                        fontSize: 14,
                                      ),
                                    ),
                              trailing: draft
                                  ? Text(
                                      '未送信',
                                      style: TextStyle(
                                        color: kRedColor,
                                        fontSize: 14,
                                      ),
                                    )
                                  : const FaIcon(
                                      FontAwesomeIcons.chevronRight,
                                      size: 16,
                                    ),
                              onTap: () {},
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                )
              : Center(
                  child: Text(
                    '送信者として登録すると利用可能になります',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
        ),
      ),
    );
  }
}
