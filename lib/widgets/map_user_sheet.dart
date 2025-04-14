import 'package:flutter/material.dart';
import 'package:simple_alert_app/common/style.dart';
import 'package:simple_alert_app/models/map_user.dart';
import 'package:simple_alert_app/widgets/map_user_list.dart';

class MapUserSheet extends StatelessWidget {
  final List<MapUserModel> sendMapUsers;

  const MapUserSheet(
    this.sendMapUsers, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.3,
      minChildSize: 0.3,
      maxChildSize: 0.6,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: kWhiteColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            boxShadow: [
              BoxShadow(
                blurRadius: 10,
                color: kBlackColor.withOpacity(0.5),
              )
            ],
          ),
          child: Column(
            children: [
              SizedBox(
                height: 30,
                child: Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: kBlackColor.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
              Text(
                '送信結果',
                style: TextStyle(
                  color: kBlackColor.withOpacity(0.5),
                  fontSize: 16,
                ),
              ),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: sendMapUsers.length,
                  itemBuilder: (context, index) {
                    MapUserModel mapUser = sendMapUsers[index];
                    return MapUserList(mapUser: mapUser);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
