import 'dart:async';
import 'dart:convert';

import 'package:flutter_mediapipe_vision/flutter_mediapipe_vision.dart';

import '../models/analyzer_message.dart';
import '../models/pose.dart';
import '../models/still.dart';
import 'analyzer.dart';

/// Emits the first recognized pose from each frame from the camera.
class PoseDetector extends Analyzer<Still, Pose> {
  @override
  Future<Pose?> process(AnalyzerMessage<Still> m) async {
    final result = await FlutterMediapipeVision.detect(m.data.bytes);

    final landmarks = result.landmarks.firstOrNull;
    if (landmarks == null) {
      return null;
    }

    return Pose(
      aspectRatio: m.data.aspectRatio,
      landmarks: landmarks,
    );
  }
}
