import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tmuf_kb_helper/data.dart';
import 'package:tmuf_kb_helper/filesystem.dart';
import 'package:tmuf_kb_helper/screens/settings.dart';
import 'package:tmuf_kb_helper/screens/viz.dart';
import 'package:window_manager/window_manager.dart';

import 'globals.dart';

final Map<String, Widget Function(BuildContext)> routes = {
  "/viz": (context) => const VizScreen(),
  "/settings": (context) => const SettingsScreen()
};

const Size settingsSize = Size(500, 475);
const Size visSize = Size(600, 350);

void main() async {
  await startListener();
  await loadSettings();
  await Data.init();
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  await Window.initialize();
  runApp(const MyApp());
  doWhenWindowReady(() {
    appWindow.title = "TMUF KB Helper";
    windowManager.setSize(settingsSize);
    windowManager.setResizable(false);
    appWindow.position = Offset.zero;
    appWindow.alignment = Alignment.center;
    appWindow.show();
  });
}

ThemeData? getThemeData(BuildContext context) => ThemeData.dark().copyWith(
  scaffoldBackgroundColor: bgColor,
  backgroundColor: Colors.transparent,
  textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme).apply(bodyColor: textColor),
  canvasColor: bgColor,
  primaryColor: primaryColor,
  iconTheme: Theme.of(context).iconTheme.copyWith(color: primaryColor),
  inputDecorationTheme: Theme.of(context).inputDecorationTheme.copyWith(
    focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: primaryColor)),
    enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
    hintStyle: const TextStyle(color: Colors.grey),
  ),
  appBarTheme: Theme.of(context).appBarTheme.copyWith(elevation: 0, backgroundColor: secondaryColor)
);

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //rebuildAllChildren(context);
    topLevelContext = context;
    return MaterialApp(
      title: 'TMUF KB Helper',
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: snackbarKey,
      theme: getThemeData(context),
      initialRoute: "/settings",
      routes: routes
    );
  }
}