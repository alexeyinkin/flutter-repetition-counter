import 'package:flutter_mediapipe_vision/flutter_mediapipe_vision.dart';

/// Calculates a metric from a pose.
abstract class MetricCalculator {
  final String title;

  const MetricCalculator({required this.title});

  double calculate(List<NormalizedLandmark> pose, double aspectRatio);
}
