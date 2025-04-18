import 'package:flutter/material.dart';
import 'package:simple_alert_app/common/style.dart';

class CustomCheckList extends StatelessWidget {
  final String label;
  final bool? value;
  final Function(bool?)? onChanged;
  final Color? activeColor;

  const CustomCheckList({
    required this.label,
    required this.value,
    required this.onChanged,
    this.activeColor = kBlueColor,
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
      child: CheckboxListTile(
        title: Text(label),
        value: value,
        onChanged: onChanged,
        activeColor: activeColor,
      ),
    );
  }
}
