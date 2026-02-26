import 'dart:async';
import 'dart:convert';

import 'package:flutter_mediapipe_vision/flutter_mediapipe_vision.dart';

import '../models/analyzer_message.dart';
import '../models/pose.dart';
import '../models/still.dart';
import 'analyzer.dart';

/// Emits the first recognized pose from each frame from the camera.
class PoseDetector extends Analyzer<Still, Pose> {
  final int recordFirstTicks;
  final _recorded = <PoseLandmarkerResult>[];
  bool _dumped = false;

  PoseDetector({this.recordFirstTicks = -1});

  @override
  Future<Pose?> process(AnalyzerMessage<Still> m) async {
    final still = m.data;
    var result = await switch (still) {
      EncodedStill() => FlutterMediapipeVision.detect(still.bytes),
      PlanesStill() => FlutterMediapipeVision.detectOnPlanes(
        still.planes,
        width: still.width,
        height: still.height,
      ),
    };

    for (int n = still.needsClockwiseQuarterTurns; --n >= 0;) {
      result = result.quarterTurnedClockwise;
    }
    if (still.needsHorizontalFlipping) {
      result = result.flippedHorizontally;
    }

    if (m.tick < recordFirstTicks) {
      _recorded.add(result);
    } else if (m.tick >= recordFirstTicks && !_dumped) {
      print(jsonEncode(_recorded)); // ignore: avoid_print
      _dumped = true;
    }

    final landmarks = result.landmarks.firstOrNull;
    if (landmarks == null) {
      return null;
    }

    return Pose(
      aspectRatio: still.needsClockwiseQuarterTurns.isEven
          ? m.data.aspectRatio
          : 1 / m.data.aspectRatio,
      landmarks: landmarks,
    );
  }
}

extension on PoseLandmarkerResult {
  PoseLandmarkerResult get flippedHorizontally => PoseLandmarkerResult(
    landmarks: landmarks
        .map((pose) => pose.flippedHorizontally)
        .toList(growable: false),
  );

  PoseLandmarkerResult get quarterTurnedClockwise => PoseLandmarkerResult(
    landmarks: landmarks
        .map((pose) => pose.quarterTurnedClockwise)
        .toList(growable: false),
  );
}

extension on List<NormalizedLandmark> {
  List<NormalizedLandmark> get flippedHorizontally => [
    for (final lm in this) lm.flippedHorizontally,
  ];

  List<NormalizedLandmark> get quarterTurnedClockwise => [
    for (final lm in this) lm.quarterTurnedClockwise,
  ];
}

extension on NormalizedLandmark {
  NormalizedLandmark get flippedHorizontally =>
      NormalizedLandmark(x: 1 - x, y: y, z: z, visibility: visibility);

  NormalizedLandmark get quarterTurnedClockwise =>
      NormalizedLandmark(x: 1 - y, y: x, z: z, visibility: visibility);
}
