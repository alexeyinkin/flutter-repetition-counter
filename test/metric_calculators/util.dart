import 'package:flutter_mediapipe_vision/flutter_mediapipe_vision.dart';

NormalizedLandmark nl(double x, double y) =>
    NormalizedLandmark(x: x, y: y, z: x + y, visibility: x - y);
