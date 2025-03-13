import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:simple_alert_app/common/style.dart';

class ReminderScreen extends StatelessWidget {
  const ReminderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Card(
          color: kWhiteColor,
          elevation: 0,
          child: ListView.builder(
            itemCount: 100,
            itemBuilder: (context, index) {
              return Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: kBlackColor.withOpacity(0.5),
                    ),
                  ),
                ),
                child: ListTile(
                  title: Text('リマインダー$index'),
                  trailing: const FaIcon(FontAwesomeIcons.chevronRight),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
