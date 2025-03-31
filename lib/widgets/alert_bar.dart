import 'package:flutter/material.dart';
import 'package:simple_alert_app/common/style.dart';

class AlertBar extends StatelessWidget {
  final String label;

  const AlertBar(
    this.label, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      width: double.infinity,
      color: kRedColor,
      padding: EdgeInsets.all(8),
      child: Text(
        label,
        style: TextStyle(
          color: kWhiteColor,
          fontWeight: FontWeight.bold,
          fontFamily: 'SourceHanSansJP-Bold',
        ),
      ),
    );
  }
}
