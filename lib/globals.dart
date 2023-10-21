import 'package:flutter/material.dart';

const int guiPort = 33333;
const int kblPort = 33334;

const Color primaryColor = Color.fromARGB(255, 22, 108, 189);
const Color secondaryColor = Color(0xFF2A2D3E);
const Color bgColor = Color(0xFF212332);
const Color textColor = Color.fromARGB(255, 255, 255, 255);
const EdgeInsetsGeometry defaultPadding = EdgeInsets.all(8.0);
const TextStyle textStyle = TextStyle(color: textColor, fontSize: 14);
const TextStyle subtitleStyle = TextStyle(color: textColor, fontSize: 20);
const TextStyle titleStyle = TextStyle(color: textColor, fontSize: 30);

late BuildContext topLevelContext; // Big danger here but idc

final GlobalKey<ScaffoldMessengerState> snackbarKey = GlobalKey<ScaffoldMessengerState>();

void rebuildAllChildren(BuildContext context) {
  void rebuild(Element el) {
    el.markNeedsBuild();
    el.visitChildren(rebuild);
  }
  (context as Element).visitChildren(rebuild);
}

ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showError(BuildContext context, String message){
  return ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
    )
  );
}

ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showInfo(BuildContext context, String message){
  return ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: Colors.green,
    )
  );
}