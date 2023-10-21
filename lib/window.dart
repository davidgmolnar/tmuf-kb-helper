import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:tmuf_kb_helper/data.dart';
import 'package:tmuf_kb_helper/filesystem.dart';
import 'package:tmuf_kb_helper/globals.dart';

const titlebarHeight = 25 + 5; // Windows default

class CustomCloseButton extends StatefulWidget {
  const CustomCloseButton({super.key});

  @override
  State<CustomCloseButton> createState() => _CustomCloseButtonState();
}

class _CustomCloseButtonState extends State<CustomCloseButton> {
  bool isHover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (event) => {isHover = true, setState(() {})},
      onExit: (event) => {isHover = false, setState(() {})},
      child: TextButton(
        onPressed: () async {
          Data.send(killMsg);
          await saveSettings();
          Data.sock.close();
          appWindow.close();
        },
        child: CloseIcon(color: isHover ? Colors.red : textColor,)
      ),
    );
  }
}

class CustomMinimizeButton extends StatelessWidget {
  const CustomMinimizeButton({super.key});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        appWindow.minimize();
      },
      child: SizedBox( // MinimizeIcon and RestoreIcon had wrong painter calculations and it constantly wiggled around
        height: 40,
        width: 40,
        child: Center(
          child: Container(
            height: 2,
            width: 10,
            color: textColor,
          )
        ),
      )
    );
  }
}

class CustomRestoreButton extends StatefulWidget {
  const CustomRestoreButton({super.key});

  @override
  State<CustomRestoreButton> createState() => _CustomRestoreButtonState();
}

class _CustomRestoreButtonState extends State<CustomRestoreButton> {

  void maximizeOrRestore() {
    setState(() {
      appWindow.maximizeOrRestore();
    });
  }

  @override
  Widget build(BuildContext context) {
    return appWindow.isMaximized ?
      TextButton(onPressed: () {
        maximizeOrRestore();
      }, child: RestoreIcon(color: textColor,))
      :
      TextButton(onPressed: () {
        maximizeOrRestore();
      }, child: SizedBox( // MinimizeIcon and RestoreIcon had wrong painter calculations and it constantly wiggled around
        height: 40,
        width: 40,
        child: Center(
          child: Container(
            height: 10,
            width: 10,
            decoration: BoxDecoration(border: Border.all(width: 1, color: textColor)),
          )
        ),
      ));
  }
}

class WindowButtons extends StatefulWidget {
  const WindowButtons({Key? key}) : super(key: key);
  
  @override
  State<StatefulWidget> createState() => _WindowButtonsState();
}

class _WindowButtonsState extends State<WindowButtons> {
  void maximizeOrRestore() {
    setState(() {
      appWindow.maximizeOrRestore();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: secondaryColor,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: const [
          CustomMinimizeButton(),
          CustomRestoreButton(),
          CustomCloseButton()
        ],
      ),
    );
  }
}