import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

Future showBottomUpScreen(BuildContext context, Widget widget) async {
  await showMaterialModalBottomSheet(
    expand: true,
    isDismissible: false,
    enableDrag: false,
    context: context,
    builder: (context) => widget,
  );
}

String dateText(String format, DateTime? date) {
  String ret = '';
  if (date != null) {
    ret = DateFormat(format, 'ja').format(date);
  }
  return ret;
}
