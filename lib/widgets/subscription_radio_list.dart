import 'package:flutter/material.dart';
import 'package:simple_alert_app/common/style.dart';

class SubscriptionRadioList extends StatelessWidget {
  final String label;
  final String annotation;
  final int value;
  final int groupValue;
  final Function(int?)? onChanged;

  const SubscriptionRadioList({
    required this.label,
    required this.annotation,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: kBlackColor.withOpacity(0.5)),
          borderRadius: BorderRadius.circular(8),
          color: value == groupValue ? kRedColor.withOpacity(0.3) : kWhiteColor,
        ),
        child: RadioListTile(
          title: Text(
            label,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'SourceHanSansJP-Bold',
            ),
          ),
          subtitle: Text(
            annotation,
            style: TextStyle(
              color: kRedColor,
              fontSize: 16,
            ),
          ),
          value: value,
          groupValue: groupValue,
          onChanged: onChanged,
          activeColor: kRedColor,
        ),
      ),
    );
  }
}
