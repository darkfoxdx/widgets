
import 'package:flutter/material.dart';

class EmbossShadowContainer extends StatelessWidget {
  const EmbossShadowContainer({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      height: 200,
      decoration: BoxDecoration(
          color: Color(0xFF41464C),
          borderRadius: BorderRadius.all(Radius.circular(20)),
          border: Border.all(color: Color(0xFF52575D), width: 5),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              offset: Offset(-3.0, -6.0),
              blurRadius: 8.0,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              offset: Offset(3.0, 6.0),
              blurRadius: 5.0,
            ),
          ]),
    );
  }
}