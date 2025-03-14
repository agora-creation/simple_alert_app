import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:simple_alert_app/common/style.dart';

class NoticeList extends StatelessWidget {
  final String label;
  final Function()? onTap;

  const NoticeList({
    required this.label,
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
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: 'SourceHanSansJP-Bold',
          ),
        ),
        subtitle: Text(
          '2025/03/25 12:59',
          style: TextStyle(
            color: kBlackColor.withOpacity(0.8),
            fontSize: 14,
          ),
        ),
        trailing: const FaIcon(
          FontAwesomeIcons.chevronRight,
          size: 16,
        ),
        onTap: onTap,
      ),
    );
  }
}
