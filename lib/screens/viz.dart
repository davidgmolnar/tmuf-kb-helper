import 'package:flutter/material.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:tmuf_kb_helper/components/appbar.dart';
import 'package:tmuf_kb_helper/data.dart';
import 'package:tmuf_kb_helper/globals.dart';
import 'package:tmuf_kb_helper/main.dart';
import 'package:window_manager/window_manager.dart';

class VizScreen extends StatelessWidget {
  const VizScreen({super.key});

  @override
  Widget build(BuildContext context) {
    windowManager.setSize(visSize);
    windowManager.setResizable(true);
    Window.setEffect(
      effect: WindowEffect.transparent
    );
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: const [
          CustomAppBar(),
          Expanded(child: VizBody()),
        ],
      ),
    );
  }
}

class VizBody extends StatefulWidget {
  const VizBody({super.key});

  @override
  State<VizBody> createState() => _VizBodyState();
}

class _VizBodyState extends State<VizBody> {

  @override
  void initState() {
    Data.statusNotifier.addListener(update);
    super.initState();
  }

  void update() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (p0, p1) {
        return RawKeyboardListener(
          focusNode: FocusNode()..requestFocus(),
          child: SizedBox(
            height: p1.maxHeight,
            width: p1.maxWidth,
            child: CustomPaint(
              painter: VizPainter(),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    Data.statusNotifier.removeListener(update);
    super.dispose();
  }
}

class VizPainter extends CustomPainter {

  double tl(final double x, final double inset, final double steepness, final double dx){
    return (x - inset) * steepness + dx;
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(1, -1);
    canvas.translate(0, -size.height);
    final Paint paintBase = Paint()..style = PaintingStyle.fill;

    final Color accelColor = Data.statusNotifier.value.accel ? Colors.green : secondaryColor;
    final Color brakeColor = Data.statusNotifier.value.brake ? Colors.red : secondaryColor;
    final Color steerLeftColor = Data.statusNotifier.value.steerLeft ? Colors.orange : secondaryColor;
    final Color steerRightColor = Data.statusNotifier.value.steerRight ? Colors.orange : secondaryColor;

    double padding = (size.width + size.height) / 2 * 0.025;
    const double inset = 30;

    final double steepness = (size.height * 0.5 - inset) / (size.width * 0.5 - inset);

    Path steerLeft = Path();
    steerLeft.moveTo(inset, size.height * 0.5);
    steerLeft.lineTo(size.width * 0.4 - padding, tl(size.width * 0.4 - padding, inset, steepness, size.height * 0.5));
    steerLeft.lineTo(size.width * 0.4 - padding, tl(size.width * 0.4 - padding, inset, -steepness, size.height * 0.5));
    steerLeft.lineTo(inset, size.height * 0.5);
    canvas.drawPath(steerLeft, paintBase..color = steerLeftColor);

    Path steerRight = Path();
    steerRight.moveTo(size.width - inset, size.height * 0.5);
    steerRight.lineTo(size.width * 0.6 + padding, tl(size.width * 0.4 - padding, inset, steepness, size.height * 0.5));
    steerRight.lineTo(size.width * 0.6 + padding, tl(size.width * 0.4 - padding, inset, -steepness, size.height * 0.5));
    steerRight.lineTo(size.width - inset, size.height * 0.5);
    canvas.drawPath(steerRight, paintBase..color = steerRightColor);

    Path accel = Path();
    accel.moveTo(size.width * 0.5, tl(size.width * 0.5, inset, steepness, size.height * 0.5));
    accel.lineTo(size.width * 0.4, tl(size.width * 0.4, inset, steepness, size.height * 0.5));
    accel.lineTo(size.width * 0.4, size.height * 0.5 + padding / 2);
    accel.lineTo(size.width * 0.6, size.height * 0.5 + padding / 2);
    accel.lineTo(size.width * 0.6, tl(size.width * 0.4, inset, steepness, size.height * 0.5));
    accel.lineTo(size.width * 0.5, tl(size.width * 0.5, inset, steepness, size.height * 0.5));
    canvas.drawPath(accel, paintBase..color = accelColor);

    Path brake = Path();
    brake.moveTo(size.width * 0.5, tl(size.width * 0.5, inset, -steepness, size.height * 0.5));
    brake.lineTo(size.width * 0.4, tl(size.width * 0.4, inset, -steepness, size.height * 0.5));
    brake.lineTo(size.width * 0.4, size.height * 0.5 - padding / 2);
    brake.lineTo(size.width * 0.6, size.height * 0.5 - padding / 2);
    brake.lineTo(size.width * 0.6, tl(size.width * 0.4, inset, -steepness, size.height * 0.5));
    brake.lineTo(size.width * 0.5, tl(size.width * 0.5, inset, -steepness, size.height * 0.5));
    canvas.drawPath(brake, paintBase..color = brakeColor);
  }

  @override
  bool shouldRepaint(VizPainter oldDelegate) => true;

  @override
  bool shouldRebuildSemantics(VizPainter oldDelegate) => false;
}
