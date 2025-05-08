import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:simple_alert_app/common/style.dart';
import 'package:simple_alert_app/models/user_send.dart';

class SendDetailChartScreen extends StatelessWidget {
  final UserSendModel userSend;

  const SendDetailChartScreen({
    required this.userSend,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    Map<String, double> dataMap = {};
    dataMap['未回答'] = 0;
    if (userSend.choices.isNotEmpty) {
      for (final choice in userSend.choices) {
        dataMap[choice] = 0;
      }
    }
    if (userSend.sendUsers.isNotEmpty) {
      for (final sendUser in userSend.sendUsers) {
        if (dataMap.containsKey(sendUser.answer)) {
          dataMap[sendUser.answer] = dataMap[sendUser.answer]! + 1;
        } else {
          dataMap['未回答'] = dataMap['未回答']! + 1;
        }
      }
    }
    return Scaffold(
      backgroundColor: kWhiteColor,
      appBar: AppBar(
        backgroundColor: kWhiteColor,
        automaticallyImplyLeading: false,
        title: const Text(
          '回答の割合',
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: PieChart(
            dataMap: dataMap,
            legendOptions: LegendOptions(legendPosition: LegendPosition.bottom),
            chartValuesOptions: ChartValuesOptions(decimalPlaces: 0),
          ),
        ),
      ),
    );
  }
}
