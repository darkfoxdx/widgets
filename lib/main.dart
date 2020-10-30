import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

import 'utils/custom_curved_animation.dart';

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

extension IndexedIterable<E> on Iterable<E> {
  Iterable<T> mapIndexed<T>(T Function(E e, int i) f) {
    var i = 0;
    return map((e) => f(e, i++));
  }
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  CustomCurvedAnimation _curvedAnimationController;
  List<int> list = List.filled(3, 0);
  double radius = 20;
  bool isExpanded = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this);
    repeat();
    _curvedAnimationController = CustomCurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutQuad,
      reverseCurve: Curves.easeOutQuad.flipped,
    );
  }

  @override
  void dispose() {
    super.dispose();
    _animationController.dispose();
  }

  void repeat() {
    _animationController?.repeat(reverse: true, period: Duration(seconds: 5));
  }

  Offset generateIdlePosition(
    int index,
    int length, {
    double xOffset,
    double yOffset,
    double dy,
  }) {
    var number = length - 1 - index;
    var y = yOffset + dy * number;
    var x = xOffset;
    return Offset(x, y);
  }

  double generateIdleScale(int index, int length, {double scale = 0.1}) {
    var number = length - 1 - index;
    return max(1 - 0.1 * number, 0.0);
  }

  Matrix4 generateIdleAnimationMatrix(
    int index,
    int length,
    Offset position,
    double scale, {
    double dy = 0,
    double animationValue = 0,
  }) {
    var number = length - 1 - index;
    var y = lerpDouble(position.dy, position.dy + dy * number, animationValue);
    var x = position.dx;
    // print(offset);
    return Matrix4.identity()
      ..setTranslationRaw(x, y, 0.0)
      ..scale(scale, scale, 1);
  }

  Color generateIdleColor(int index, int length, Color initialColor) {
    var number = length - index;
    var hsv = HSVColor.fromColor(initialColor);
    var value = max(hsv.value - number * 0.15, 0);
    return hsv.withValue(value).toColor();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SafeArea(
        child: Container(
          child: LayoutBuilder(
            builder: (context, constraint) {
              var width = constraint.maxWidth;
              var height = constraint.maxHeight;
              return Container(
                width: width,
                height: height,
                color: Color(0xFF29253F),
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    var animationValue = _curvedAnimationController.value;
                    var size = 200.0;
                    var minYOffset = 10.0;
                    var move = 10.0;
                    var primaryColor = Color(0xFFE5E5E5);
                    var centerX = (width - size) / 2;
                    var centerY =
                        (height - size) / 2 - minYOffset * (list.length - 1);
                    return Stack(
                      children: [
                        ...list.mapIndexed((e, i) {
                          var position = generateIdlePosition(
                            i,
                            list.length,
                            xOffset: centerX,
                            yOffset: centerY,
                            dy: minYOffset,
                          );
                          var scale = generateIdleScale(i, list.length);
                          var color =
                              generateIdleColor(i, list.length, primaryColor);

                          Matrix4 matrix;
                          if (isExpanded) {
                            matrix = Matrix4.identity()
                              ..setTranslationRaw(position.dx, position.dy, 0.0)
                              ..scale(scale, scale, 1);
                          } else {
                            matrix = generateIdleAnimationMatrix(
                                i, list.length, position, scale,
                                dy: move, animationValue: animationValue);
                          }
                          return Transform(
                            transform: matrix,
                            alignment: Alignment.bottomCenter,
                            child: InkWell(
                              onTap: i == list.length - 1
                                  ? () async {
                                      if (isExpanded) {
                                        await _animationController.animateTo(0,
                                            duration: Duration(seconds: 1));
                                        repeat();
                                      } else {
                                        _animationController.animateTo(1,
                                            duration: Duration(seconds: 1));
                                      }
                                      isExpanded = !isExpanded;
                                    }
                                  : null,
                              child: Container(
                                width: size,
                                height: size,
                                decoration: BoxDecoration(
                                  color: color,
                                  borderRadius: BorderRadius.circular(radius),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ],
                    );
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
