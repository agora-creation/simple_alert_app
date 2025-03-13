import 'package:floating_navigation_bar/floating_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:simple_alert_app/common/style.dart';

class CustomNavigationBar extends StatelessWidget {
  final List<NavBarItems> items;
  final Function(int) onChanged;

  const CustomNavigationBar({
    required this.items,
    required this.onChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: FloatingNavigationBar(
        backgroundColor: kWhiteColor,
        barHeight: 80,
        barWidth: MediaQuery.of(context).size.width - 40,
        iconColor: kBlackColor,
        textStyle: TextStyle(
          color: kBlackColor,
          fontSize: 14,
        ),
        iconSize: 18,
        indicatorColor: kRedColor,
        indicatorHeight: 4,
        indicatorWidth: 20,
        items: items,
        onChanged: onChanged,
      ),
    );
  }
}
