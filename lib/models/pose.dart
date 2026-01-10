import 'package:flutter_mediapipe_vision/flutter_mediapipe_vision.dart';

class Pose {
  /// Width:height of the source image.
  ///
  /// Since the pose point coordinates are normalized to the source image,
  /// metrics need to be adjusted for the image aspect ratio
  /// for the angles to be true and the lengths to be invariant of rotation.
  final double aspectRatio;

  final List<NormalizedLandmark> landmarks;

  const Pose({required this.aspectRatio, required this.landmarks});
}
