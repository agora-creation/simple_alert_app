import 'package:flutter/material.dart';
import 'package:simple_alert_app/common/style.dart';
import 'package:simple_alert_app/models/send_user.dart';
import 'package:simple_alert_app/widgets/send_user_list.dart';

class SendUserSheet extends StatelessWidget {
  final List<SendUserModel> sendUsers;
  final Widget? action;

  const SendUserSheet(
    this.sendUsers, {
    this.action,
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Text(
                      '送信結果',
                      style: TextStyle(
                        color: kBlackColor.withOpacity(0.5),
                        fontSize: 16,
                      ),
                    ),
                  ),
                  action ?? Container(),
                ],
              ),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: sendUsers.length,
                  itemBuilder: (context, index) {
                    SendUserModel sendUser = sendUsers[index];
                    return SendUserList(sendUser: sendUser);
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
