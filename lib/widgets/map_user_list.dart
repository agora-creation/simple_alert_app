import 'package:flutter/material.dart';
import 'package:simple_alert_app/common/style.dart';
import 'package:simple_alert_app/models/map_user.dart';

class MapUserList extends StatelessWidget {
  final MapUserModel mapUser;

  const MapUserList({
    required this.mapUser,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: kBlackColor.withOpacity(0.5)),
        ),
      ),
      child: ListTile(
        title: Text(mapUser.name),
        trailing: Text(
          mapUser.answer,
          style: TextStyle(
            color: kRedColor,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'SourceHanSansJP-Bold',
          ),
        ),
      ),
    );
  }
}
