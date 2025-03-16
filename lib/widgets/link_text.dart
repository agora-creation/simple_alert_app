import 'package:flutter/material.dart';
import 'package:simple_alert_app/common/style.dart';

class LinkText extends StatelessWidget {
  final String label;
  final Color color;
  final Function()? onTap;

  const LinkText({
    required this.label,
    this.color = kRedColor,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 16,
          decoration: TextDecoration.underline,
          decorationColor: color,
        ),
      ),
    );
  }
}
