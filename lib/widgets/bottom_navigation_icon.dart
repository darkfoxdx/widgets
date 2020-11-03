import 'package:flutter/material.dart';

class NavigationIcon extends StatelessWidget {
  final EdgeInsets margin;
  final Function() onPressed;
  final Widget child;

  const NavigationIcon({
    Key key,
    this.margin,
    this.onPressed,
    this.child,
  }) : super(key: key);

  factory NavigationIcon.animatedIcon(AnimatedIconData icon,
      {Function() onPressed,
      EdgeInsets margin,
      double size,
      Animation<double> animationController}) {
    return NavigationIcon(
      child: AnimatedIcon(
        size: size ?? 24.0,
        icon: icon,
        color: Colors.white,
        progress: animationController,
      ),
      onPressed: onPressed,
      margin: margin,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.all(15),
      child: InkWell(
        onTap: onPressed,
        child: child,
      ),
    );
  }
}
