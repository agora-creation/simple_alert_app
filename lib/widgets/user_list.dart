import 'package:flutter/material.dart';
import 'package:simple_alert_app/common/style.dart';

class UserList extends StatelessWidget {
  final String label;
  final Widget? subtitle;
  final Widget? trailing;
  final Color? tileColor;
  final Function()? onTap;

  const UserList({
    required this.label,
    this.subtitle,
    this.trailing,
    this.tileColor,
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
        title: Text(label),
        subtitle: subtitle,
        trailing: trailing,
        tileColor: tileColor,
        onTap: onTap,
      ),
    );
  }
}
