import 'dart:math';

import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  bool isOpen = false;

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));
  }

  @override
  void dispose() {
    super.dispose();
    _animationController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(
        child: Stack(
          children: [
            AnimatedBuilder(
              animation: _animationController,
              builder: (BuildContext context, Widget child) {
                return CustomPaint(
                  size: Size(MediaQuery.of(context).size.width, 200),
                  painter: ShapePainter(progress: _animationController.value),
                  child: child,
                );
              },
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: 200,
                alignment: Alignment(0.95, 0.65),
                child: IconButton(
                  icon: AnimatedIcon(
                      icon: AnimatedIcons.menu_close,
                      progress: _animationController),
                  onPressed: () {
                    isOpen = !isOpen;
                    if (isOpen) {
                      _animationController.forward();
                    } else {
                      _animationController.reverse();
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ShapePainter extends CustomPainter {
  final double progress;

  ShapePainter({this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    num degToRad(num deg) => deg * (pi / 180.0);

    var paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 5
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round;

    var radius = size.height / 4;
    var inverseProgress = 1 - progress;
    var semiCircleLeft = (size.width * inverseProgress - radius) * inverseProgress - radius;
    var canvasSize = Rect.fromLTWH(0, 0, size.width, size.height);
    var pathSize = Rect.fromLTWH(0, 0, radius * 2, radius * 2);
    var semiCircleRect =
        Rect.fromLTWH(semiCircleLeft, radius * 2, radius * 2, radius * 2);

    var rectangleRect =
        Rect.fromLTWH(semiCircleRect.right - radius - 1, size.height / 2, size.width + 2, size.height);

    canvas.clipRect(canvasSize);
    canvas.drawColor(Colors.red, BlendMode.src);

    Path path = Path()
      ..arcTo(pathSize, degToRad(0), degToRad(90), true)
      ..lineTo(radius * 2 + 1, radius * 2 + 1);
    canvas.save();
    canvas.translate(canvasSize.width - radius * 2, 0);
    canvas.drawPath(path, paint);
    canvas.restore();
    canvas.drawArc(semiCircleRect, degToRad(90), degToRad(180), true, paint);
    canvas.drawRect(rectangleRect, paint);
  }

  @override
  bool shouldRepaint(ShapePainter oldDelegate) {
    return oldDelegate.progress != this.progress;
  }
}
