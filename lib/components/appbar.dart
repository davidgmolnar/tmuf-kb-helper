import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:tmuf_kb_helper/globals.dart';
import 'package:tmuf_kb_helper/main.dart';
import 'package:tmuf_kb_helper/window.dart';

class CustomAppBar extends StatelessWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: 40,
      actions: [
        Expanded(
          child: MoveWindow(
            child: Container(
              padding: defaultPadding,
              alignment: Alignment.center,
              child: const Text("TMUF KB Helper"),
            ),
          ),
        ),
        for(String route in routes.keys)
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                PageRouteBuilder(pageBuilder: ((context, animation, secondaryAnimation) {
                  return routes[route]!(context);
                }),
                transitionDuration: Duration.zero,
                reverseTransitionDuration: Duration.zero)
              );
            },
            child: Padding(
              padding: defaultPadding,
              child: Text(route, style: textStyle,),
            ),
          ),
        const WindowButtons()
      ],
    );
  }
}