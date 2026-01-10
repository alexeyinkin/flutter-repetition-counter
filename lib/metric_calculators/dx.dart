import 'package:flutter_mediapipe_vision/flutter_mediapipe_vision.dart';

import 'metric_calculator.dart';

/// Calculates the X projection of the line between two points of a pose.
class DxCalculator extends MetricCalculator {
  final int p1;
  final int p2;

  const DxCalculator(this.p1, this.p2, {required super.title});

  @override
  double calculate(List<NormalizedLandmark> pose, double aspectRatio) {
    return (pose[p2].x - pose[p1].x) * aspectRatio;
  }
}
