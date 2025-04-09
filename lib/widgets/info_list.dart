import 'package:flutter/material.dart';
import 'package:simple_alert_app/common/style.dart';

class InfoList extends StatelessWidget {
  final String label;
  final Widget? trailing;
  final Function()? onTap;

  const InfoList({
    required this.label,
    this.trailing,
    this.onTap,
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
      child: ListTile(
        title: Text(
          label,
          style: TextStyle(fontSize: 16),
        ),
        trailing: trailing,
        onTap: onTap,
      ),
    );
  }
}
