import 'package:flutter/material.dart';
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
