import 'package:flutter/material.dart';
import 'package:simple_alert_app/common/style.dart';
import 'package:simple_alert_app/providers/user.dart';

class ModeRadioList extends StatelessWidget {
  final String label;
  final Mode value;
  final Mode groupValue;
  final Function(Mode?)? onChanged;

  const ModeRadioList({
    required this.label,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return RadioListTile(
      title: Text(
        label,
        style: value == groupValue
            ? TextStyle(
                color: kRedColor,
                fontWeight: FontWeight.bold,
                fontFamily: 'SourceHanSansJP-Bold',
              )
            : null,
      ),
      value: value,
      groupValue: groupValue,
      onChanged: onChanged,
      activeColor: kRedColor,
      tileColor: kWhiteColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
