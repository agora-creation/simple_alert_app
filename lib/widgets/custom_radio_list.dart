import 'package:flutter/material.dart';
import 'package:simple_alert_app/common/style.dart';

class CustomRadioList extends StatelessWidget {
  final String label;
  final String value;
  final String groupValue;
  final Function(String?)? onChanged;

  const CustomRadioList({
    required this.label,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: kBlackColor.withOpacity(0.5),
        ),
        color: kWhiteColor,
      ),
      child: RadioListTile(
        title: Text(label),
        value: value,
        groupValue: groupValue,
        onChanged: onChanged,
        activeColor: kBlueColor,
      ),
    );
  }
}
