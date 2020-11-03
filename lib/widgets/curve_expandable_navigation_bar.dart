import 'dart:math';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'bottom_navigation_icon.dart';

class CurveExpandableNavigationBar extends StatefulWidget {
  final int milliseconds;
  final Function(bool) onCompleted;
  final List<Widget> buttons;
  final Color backgroundColor;

  const CurveExpandableNavigationBar({
    Key key,
    this.milliseconds = 300,
    this.onCompleted,
    this.buttons = const [],
    this.backgroundColor = Colors.white,
  }) : super(key: key);

  @override
  _CurveExpandableNavigationBarState createState() =>
      _CurveExpandableNavigationBarState();
}

class _CurveExpandableNavigationBarState
    extends State<CurveExpandableNavigationBar>
    with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
        vsync: this, duration: Duration(milliseconds: widget.milliseconds));
    _animationController.addStatusListener((status) {
      switch (status) {
        case AnimationStatus.dismissed:
          break;
        case AnimationStatus.forward:
          break;
        case AnimationStatus.reverse:
          break;
        case AnimationStatus.completed:
          widget.onCompleted?.call(_isOpen);
          break;
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _animationController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = 120.0;
    final diameter = height / 2;
    final radius = diameter / 2;
    return Container(
      width: width,
      height: height,
      child: Stack(
        children: [
          AnimatedBuilder(
            animation: _animationController,
            builder: (BuildContext context, Widget child) {
              return CustomPaint(
                size: Size(width, height),
                painter: ShapePainter(
                  color: widget.backgroundColor,
                  progress: _animationController.value,
                ),
                child: child,
              );
            },
          ),
          AnimatedBuilder(
            animation: _animationController,
            builder: (BuildContext context, Widget child) {
              return Positioned(
                bottom: 0,
                left: _leftBarValue(width, radius, _animationController.value),
                child: child,
              );
            },
            child: Container(
              margin: EdgeInsets.only(left: radius),
              width: width - diameter,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: widget.buttons,
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: ClipRRect(
              borderRadius:
                  BorderRadius.horizontal(left: Radius.circular(radius)),
              child: Container(
                width: diameter,
                color: widget.backgroundColor,
                child: NavigationIcon.animatedIcon(
                  AnimatedIcons.menu_close,
                  margin: const EdgeInsets.all(15),
                  size: radius,
                  animationController: _animationController,
                  onPressed: () {
                    _isOpen = !_isOpen;
                    if (_isOpen) {
                      _animationController.forward();
                    } else {
                      _animationController.reverse();
                    }
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

double _leftBarValue(double width, double radius, double progress) {
  var inverseProgress = 1 - progress;
  return (width * inverseProgress - radius) * inverseProgress - radius;
}

class ShapePainter extends CustomPainter {
  final double progress;
  final Color color;

  ShapePainter({this.progress, this.color});

  @override
  void paint(Canvas canvas, Size size) {
    num degToRad(num deg) => deg * (pi / 180.0);

    var paint = Paint()
      ..color = this.color ?? Colors.white
      ..strokeWidth = 5
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round;

    var radius = size.height / 4;
    var semiCircleLeft = _leftBarValue(size.width, radius, progress);
    var canvasSize = Rect.fromLTWH(0, 0, size.width, size.height);
    var pathSize = Rect.fromLTWH(0, 0, radius * 2, radius * 2);
    var semiCircleRect =
        Rect.fromLTWH(semiCircleLeft, radius * 2, radius * 2, radius * 2);

    var rectangleRect = Rect.fromLTWH(semiCircleRect.right - radius - 1,
        size.height / 2, size.width + 2, size.height);

    canvas.clipRect(canvasSize);

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
