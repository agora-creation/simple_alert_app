import 'package:flutter/material.dart';
import 'package:simple_alert_app/common/style.dart';

class CustomListButton extends StatelessWidget {
  final Widget? leading;
  final String label;
  final Color? tileColor;
  final Widget? trailing;
  final Function()? onTap;

  const CustomListButton({
    this.leading,
    required this.label,
    this.tileColor,
    this.trailing,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: leading,
      title: Text(
        label,
        style: TextStyle(
          color: kBlackColor,
          fontSize: 16,
        ),
      ),
      tileColor: tileColor,
      trailing: trailing,
      onTap: onTap,
    );
  }
}
