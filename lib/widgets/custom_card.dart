import 'package:flutter/material.dart';
import 'package:simple_alert_app/common/style.dart';

class CustomCard extends StatelessWidget {
  final Widget child;

  const CustomCard({
    required this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      color: kWhiteColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }
}
