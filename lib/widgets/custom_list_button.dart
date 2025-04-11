import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

enum ButtonVerticalAlign { top, bottom }

class CustomListButton extends StatelessWidget {
  final IconData leadingIcon;
  final String label;
  final Color labelColor;
  final Color? tileColor;
  final Function()? onTap;
  final ButtonVerticalAlign? verticalAlign;

  const CustomListButton({
    required this.leadingIcon,
    required this.label,
    required this.labelColor,
    required this.tileColor,
    this.onTap,
    this.verticalAlign = ButtonVerticalAlign.top,
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
      shape: RoundedRectangleBorder(
        borderRadius: verticalAlign == ButtonVerticalAlign.top
            ? BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              )
            : BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
      ),
    );
  }
}
