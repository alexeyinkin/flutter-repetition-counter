import 'package:flutter_mediapipe_vision/flutter_mediapipe_vision.dart';

import 'metric_calculator.dart';

class CallbackMetricCalculator extends MetricCalculator {
  final double Function(List<NormalizedLandmark> pose, double aspectRatio)
  callback;

  const CallbackMetricCalculator(this.callback, {required super.title});

  @override
  double calculate(List<NormalizedLandmark> pose, double aspectRatio) =>
      callback(pose, aspectRatio);
}
