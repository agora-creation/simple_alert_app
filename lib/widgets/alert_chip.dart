import 'package:flutter/material.dart';
import 'package:simple_alert_app/common/style.dart';

class AlertChip extends StatelessWidget {
  final String label;

  const AlertChip(
    this.label, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(
        label,
        style: TextStyle(
          color: kWhiteColor,
          fontWeight: FontWeight.bold,
          fontFamily: 'SourceHanSansJP-Bold',
        ),
      ),
      backgroundColor: kRedColor,
      shape: StadiumBorder(side: BorderSide.none),
    );
  }
}
