import 'dart:async';

import 'package:camera/camera.dart';

import '../const.dart';
import 'metrics.dart';
import 'pose.dart';
import 'still.dart';
import 'tick.dart';
import 'time_series.dart';

/// How many historical data points to keep.
const _length = 100; // TODO: Up for higher FPS, limit the display by time.

class AppController {
  final tickEmitter = TickEmitter(Duration(milliseconds: 1000 ~/ targetFps));
  final CameraController cameraController;

  final StillCapturer stillCapturer;
  final poseDetector = PoseDetector();
  final metricsComputer = MetricsComputer.lengths();
  final timeSeriesAccumulator = TimeSeriesAccumulator(
    length: _length,
    vectorLength: MetricsComputer.lengths().metricCalculators.length,
  );

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
    unawaited(metricsComputer.sink.addStream(poseDetector.stream));
    unawaited(timeSeriesAccumulator.sink.addStream(metricsComputer.stream));
    tickEmitter.start();
  }
}
