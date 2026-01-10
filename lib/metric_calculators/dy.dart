import 'package:flutter_mediapipe_vision/flutter_mediapipe_vision.dart';

import 'metric_calculator.dart';

/// Calculates the Y projection of the line between two points of a pose.
class DyCalculator extends MetricCalculator {
  final int p1;
  final int p2;

  const DyCalculator(this.p1, this.p2, {required super.title});

  @override
  double calculate(List<NormalizedLandmark> pose, double aspectRatio) {
    return pose[p2].y - pose[p1].y;
  }
}
