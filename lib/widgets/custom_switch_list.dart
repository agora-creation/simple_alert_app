import 'package:flutter/material.dart';
import 'package:simple_alert_app/common/style.dart';

class CustomSwitchList extends StatelessWidget {
  final String label;
  final bool value;
  final Function(bool)? onChanged;

  const CustomSwitchList({
    required this.label,
    required this.value,
    required this.onChanged,
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
      child: SwitchListTile(
        title: Text(label),
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}
