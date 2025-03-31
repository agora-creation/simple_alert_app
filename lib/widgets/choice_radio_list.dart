import 'package:flutter/material.dart';
import 'package:simple_alert_app/common/style.dart';

class ChoiceRadioList extends StatelessWidget {
  final String value;
  final String groupValue;
  final Function(String?)? onChanged;

  const ChoiceRadioList({
    required this.value,
    required this.groupValue,
    required this.onChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: kBlackColor.withOpacity(0.5),
          ),
          color: value == groupValue ? kRedColor.withOpacity(0.3) : kWhiteColor,
        ),
        child: RadioListTile(
          title: Text(value),
          value: value,
          groupValue: groupValue,
          onChanged: onChanged,
          activeColor: kRedColor,
        ),
      ),
    );
  }
}
