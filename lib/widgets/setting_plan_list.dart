import 'package:flutter/material.dart';
import 'package:simple_alert_app/common/style.dart';

class SettingPlanList extends StatelessWidget {
  final String planName;
  final List<String> planDetails;
  final List<Widget> actions;

  const SettingPlanList({
    required this.planName,
    required this.planDetails,
    required this.actions,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: kBlackColor.withOpacity(0.5),
          ),
        ),
      ),
      padding: EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ご利用中のプラン',
            style: TextStyle(fontSize: 14),
          ),
          SizedBox(height: 4),
          Container(
            color: kMsgBgColor,
            padding: EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  planName,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'SourceHanSansJP-Bold',
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: planDetails.map((planDetail) {
                    return Text(
                      planDetail,
                      style: TextStyle(fontSize: 16),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: actions,
          ),
        ],
      ),
    );
  }
}
