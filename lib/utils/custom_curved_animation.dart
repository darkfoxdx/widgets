import 'package:flutter/material.dart';

class CustomCurvedAnimation extends Animation<double> with AnimationWithParentMixin<double> {

  CustomCurvedAnimation({
    @required this.parent,
    @required this.curve,
    @required this.reverseCurve,
  }) : assert(parent != null),
        assert(curve != null) {
    _updateCurveDirection(parent.status);
    parent.addStatusListener(_updateCurveDirection);
  }

  @override
  final Animation<double> parent;

  Curve curve;

  Curve reverseCurve;

  /// The direction used to select the current curve.
  ///
  /// The curve direction is only reset when we hit the beginning or the end of
  /// the timeline to avoid discontinuities in the value of any variables this
  /// animation is used to animate.
  AnimationStatus _curveDirection;

  void _updateCurveDirection(AnimationStatus status) {
    switch (status) {
      case AnimationStatus.dismissed:
      case AnimationStatus.completed:
        _curveDirection = null;
        break;
      case AnimationStatus.forward:
        _curveDirection = AnimationStatus.forward;
        break;
      case AnimationStatus.reverse:
        _curveDirection = AnimationStatus.reverse;
        break;
    }
  }

  bool get _useForwardCurve {
    return (_curveDirection ?? parent.status) != AnimationStatus.reverse;
  }

  @override
  double get value {
    final Curve activeCurve = _useForwardCurve ? curve : reverseCurve;

    final double t = parent.value;
    if (activeCurve == null)
      return t;
    if (t == 0.0 || t == 1.0) {
      assert(() {
        final double transformedValue = activeCurve.transform(t);
        final double roundedTransformedValue = transformedValue.round().toDouble();
        if (roundedTransformedValue != t) {
          throw FlutterError(
              'Invalid curve endpoint at $t.\n'
                  'Curves must map 0.0 to near zero and 1.0 to near one but '
                  '${activeCurve.runtimeType} mapped $t to $transformedValue, which '
                  'is near $roundedTransformedValue.'
          );
        }
        return true;
      }());
      return t;
    }
    return activeCurve.transform(t);
  }

  @override
  String toString() {
    if (reverseCurve == null)
      return '$parent\u27A9$curve';
    if (_useForwardCurve)
      return '$parent\u27A9$curve\u2092\u2099/$reverseCurve';
    return '$parent\u27A9$curve/$reverseCurve\u2092\u2099';
  }
}
