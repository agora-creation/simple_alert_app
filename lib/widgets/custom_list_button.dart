import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CustomListButton extends StatelessWidget {
  final IconData leadingIcon;
  final String label;
  final Color labelColor;
  final Color? tileColor;
  final Function()? onTap;

  const CustomListButton({
    required this.leadingIcon,
    required this.label,
    required this.labelColor,
    required this.tileColor,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: FaIcon(
        leadingIcon,
        size: 16,
        color: labelColor,
      ),
      title: Text(
        label,
        style: TextStyle(
          color: labelColor,
          fontSize: 16,
        ),
      ),
      tileColor: tileColor,
      trailing: FaIcon(
        FontAwesomeIcons.chevronUp,
        size: 16,
        color: labelColor,
      ),
      onTap: onTap,
    );
  }
}
