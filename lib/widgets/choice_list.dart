import 'package:flutter/material.dart';
import 'package:simple_alert_app/common/style.dart';

class ChoiceList extends StatelessWidget {
  final String label;

  const ChoiceList(
    this.label, {
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
        ),
        child: ListTile(
          title: Text(
            label,
            style: TextStyle(fontSize: 14),
          ),
        ),
      ),
    );
  }
}
