import 'dart:async';

import 'package:camera/camera.dart';

import '../models/analyzer_message.dart';
import '../models/still.dart';
import 'analyzer.dart';

class StillCapturer extends Analyzer<void, Still> {
  final CameraController _cameraController;

  StillCapturer({required CameraController cameraController})
    : _cameraController = cameraController {
    unawaited(_initCameraController());
  }

  Future<void> _initCameraController() async {
    await _cameraController.initialize();
  }

  @override
  Future<Still?> process(AnalyzerMessage<void> m) async {
    final cv = _cameraController.value;
    if (!cv.isInitialized) {
      return null;
    }

    try {
      final file = await _cameraController.takePicture();
      final bytes = await file.readAsBytes();
      return Still(aspectRatio: cv.aspectRatio, bytes: bytes);
      // ignore: avoid_catches_without_on_clauses
    } catch (ex) {
      print(ex); // ignore: avoid_print
      return null;
    }
  }
}
