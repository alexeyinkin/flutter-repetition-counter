import 'dart:async';

import 'package:camera/camera.dart';

import '../const.dart';
import '../models/pose.dart';
import 'analyzer.dart';
import 'detectors/random.dart';
import 'event.dart';
import 'event_speaker.dart';
import 'metrics.dart';
import 'performance_monitor.dart';
import 'performance_monitors.dart';
import 'pose.dart';
import 'pose_replay.dart';
import 'still.dart';
import 'tick.dart';
import 'time_series.dart';

/// How many historical data points to keep.
const _length = 100; // TODO: Up for higher FPS, limit the display by time.

const _eventExpireTicks = _length * 3; // TODO: Use time

class AppController {
  final tickEmitter = TickEmitter(Duration(milliseconds: 1000 ~/ targetFps));
  final CameraController? cameraController;

  final StillCapturer? stillCapturer;
  final Analyzer<dynamic, Pose> poseDetector;
  final metricsComputer = MetricsComputer.lengths();
  final timeSeriesAccumulator = TimeSeriesAccumulator(
    length: _length,
    vectorLength: MetricsComputer.lengths().metricCalculators.length,
  );

  final detector = RandomDetector();
  final eventAccumulator = EventAccumulator(expireTicks: _eventExpireTicks);
  final eventSpeaker = EventSpeaker();

  final performanceMonitors = PerformanceMonitors();

  factory AppController.live({required CameraDescription camera}) {
    final cc = CameraController(
      camera,
      ResolutionPreset.low,
      enableAudio: false,
    );
    final s = StillCapturer(cameraController: cc);
    final pd = PoseDetector(recordFirstTicks: 150);
    final result = AppController._(
      cameraController: cc,
      stillCapturer: s,
      poseDetector: pd,
    );

    unawaited(s.sink.addStream(result.tickEmitter.stream));
    unawaited(pd.sink.addStream(s.stream));

    return result;
  }

  factory AppController.replay({required String assetPath}) {
    final pd = PoseReplay(assetPath: assetPath);
    final result = AppController._(
      cameraController: null,
      stillCapturer: null,
      poseDetector: pd,
    );

    unawaited(pd.sink.addStream(result.tickEmitter.stream));

    return result;
  }

  AppController._({
    required this.cameraController,
    required this.stillCapturer,
    required this.poseDetector,
  }) {
    unawaited(metricsComputer.sink.addStream(poseDetector.stream));
    unawaited(timeSeriesAccumulator.sink.addStream(metricsComputer.stream));
    unawaited(detector.sink.addStream(timeSeriesAccumulator.stream));
    unawaited(eventAccumulator.sink.addStream(detector.events));
    unawaited(eventSpeaker.tickSink.addStream(tickEmitter.stream));
    unawaited(eventSpeaker.eventSink.addStream(detector.events));

    final s = stillCapturer;
    if (s != null) {
      performanceMonitors.add(
        PerformanceMonitor(length: _length, title: 'Still')
          ..sink.addStream(s.stream),
      );
    }

    performanceMonitors.add(
      PerformanceMonitor(length: _length, title: 'Pose')
        ..sink.addStream(poseDetector.stream),
    );

    tickEmitter.start();
  }
}
