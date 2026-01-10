import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_mediapipe_vision/flutter_mediapipe_vision.dart';

import '../models/analyzer_message.dart';
import '../models/pose.dart';
import 'analyzer.dart';
import 'pose.dart';

const _aspectRatio = 4 / 3;

/// Replays poses recorded by [PoseDetector].
class PoseReplay extends Analyzer<void, Pose> {
  final String _assetPath;
  final _recorded = <PoseLandmarkerResult>[];

  PoseReplay({required String assetPath}) : _assetPath = assetPath {
    unawaited(_init());
  }

  Future<void> _init() async {
    final str = await rootBundle.loadString(_assetPath);
    final list = jsonDecode(str) as List;
    _recorded.addAll(list.map((map) => PoseLandmarkerResult.fromJson(map)));
  }

  @override
  Future<Pose?> process(AnalyzerMessage<void> m) async {
    final landmarks = _recorded.elementAtOrNull(m.tick)?.landmarks.firstOrNull;

    if (landmarks == null) {
      return null;
    }

    return Pose(aspectRatio: _aspectRatio, landmarks: landmarks);
  }
}
