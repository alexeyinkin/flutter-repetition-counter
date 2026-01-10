import 'dart:async';

import 'package:camera/camera.dart';

import '../const.dart';
import 'detectors/random.dart';
import 'event.dart';
import 'event_speaker.dart';
import 'metrics.dart';
import 'performance_monitor.dart';
import 'performance_monitors.dart';
import 'pose.dart';
import 'still.dart';
import 'tick.dart';
import 'time_series.dart';

/// How many historical data points to keep.
const _length = 100; // TODO: Up for higher FPS, limit the display by time.

const _eventExpireTicks = _length * 3; // TODO: Use time

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

  final detector = RandomDetector();
  final eventAccumulator = EventAccumulator(expireTicks: _eventExpireTicks);
  final eventSpeaker = EventSpeaker();

  final performanceMonitors = PerformanceMonitors();

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
    unawaited(detector.sink.addStream(timeSeriesAccumulator.stream));
    unawaited(eventAccumulator.sink.addStream(detector.events));
    unawaited(eventSpeaker.tickSink.addStream(tickEmitter.stream));
    unawaited(eventSpeaker.eventSink.addStream(detector.events));

    performanceMonitors.add(
      PerformanceMonitor(length: _length, title: 'Still')
        ..sink.addStream(stillCapturer.stream),
    );

    performanceMonitors.add(
      PerformanceMonitor(length: _length, title: 'Pose')
        ..sink.addStream(poseDetector.stream),
    );

    tickEmitter.start();
  }
}
