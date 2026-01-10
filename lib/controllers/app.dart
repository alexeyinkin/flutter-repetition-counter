import 'dart:async';

import 'package:camera/camera.dart';

import '../const.dart';
import 'pose.dart';
import 'still.dart';
import 'tick.dart';

class AppController {
  final tickEmitter = TickEmitter(Duration(milliseconds: 1000 ~/ targetFps));
  final CameraController cameraController;

  final StillCapturer stillCapturer;
  final poseDetector = PoseDetector();

  factory AppController({required CameraDescription camera}) {
    final cc = CameraController(
      camera,
      ResolutionPreset.low,
      enableAudio: false,
    );
    return AppController._(
      cameraController: cc,
      stillCapturer: StillCapturer(cameraController: cc),
    );
  }

  AppController._({
    required this.cameraController,
    required this.stillCapturer,
  }) {
    unawaited(stillCapturer.sink.addStream(tickEmitter.stream));
    unawaited(poseDetector.sink.addStream(stillCapturer.stream));
    tickEmitter.start();
  }
}
