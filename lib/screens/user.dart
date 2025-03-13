import 'package:flutter/material.dart';
import 'package:simple_alert_app/common/style.dart';

class UserScreen extends StatelessWidget {
  const UserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Card(
          color: kWhiteColor,
          elevation: 0,
          child: Center(
            child: Text('名無し'),
          ),
        ),
      ),
    );
  }
}
