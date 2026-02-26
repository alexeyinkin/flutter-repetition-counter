import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../const.dart';
import '../models/pose.dart';
import 'analyzer.dart';
import 'detectors/pc1.dart';
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
import 'view.dart';

/// How many historical data points to keep.
const _length = 100; // TODO: Up for higher FPS, limit the display by time.

const _eventExpireTicks = _length * 3; // TODO: Use time

/// How many dimensions to preserve in PCA.
const _dimensions = 4;

/// How many data points to analyze for PCA.
const _analyzeDataPoints = targetFps * 5; // TODO: Use time

class AppController extends ChangeNotifier {
  final tickEmitter = TickEmitter(Duration(milliseconds: 1000 ~/ targetFps));

  final StillCapturer? stillCapturer;
  final Analyzer<dynamic, Pose> poseDetector;
  final metricsComputer = MetricsComputer.lengths();
  final timeSeriesAccumulator = TimeSeriesAccumulator(
    length: _length,
    vectorLength: MetricsComputer.lengths().metricCalculators.length,
  );

  final detector = Pc1Detector(
    dimensions: _dimensions,
    analyzeDataPoints: _analyzeDataPoints,
  );
  final eventAccumulator = EventAccumulator(expireTicks: _eventExpireTicks);
  final EventSpeaker eventSpeaker;

  final performanceMonitors = PerformanceMonitors();
  final ViewController viewController;

  CameraController? get cameraController {
    final sc = stillCapturer;
    if (sc == null) return null;
    if (!sc.isPreviewAvailable) return null;
    return sc.cameraController;
  }

  factory AppController.live(SharedPreferencesWithCache pref) {
    final s = StillCapturer.create(pref);

    final pd = PoseDetector();
    final result = AppController._(
      pref: pref,
      stillCapturer: s,
      poseDetector: pd,
    );

    unawaited(s.sink.addStream(result.tickEmitter.stream));
    unawaited(pd.sink.addStream(s.stream));

    return result;
  }

  factory AppController.replay(
    SharedPreferencesWithCache pref, {
    required String assetPath,
  }) {
    final pd = PoseReplay(assetPath: assetPath);
    final result = AppController._(
      pref: pref,
      stillCapturer: null,
      poseDetector: pd,
    );

    unawaited(pd.sink.addStream(result.tickEmitter.stream));

    return result;
  }

  AppController._({
    required SharedPreferencesWithCache pref,
    required this.stillCapturer,
    required this.poseDetector,
  }) : eventSpeaker = EventSpeaker(pref),
       viewController = ViewController(pref) {
    unawaited(metricsComputer.sink.addStream(poseDetector.stream));
    unawaited(timeSeriesAccumulator.sink.addStream(metricsComputer.stream));
    unawaited(detector.sink.addStream(timeSeriesAccumulator.stream));
    unawaited(eventAccumulator.sink.addStream(detector.events));
    unawaited(eventSpeaker.tickSink.addStream(tickEmitter.stream));
    unawaited(eventSpeaker.eventSink.addStream(detector.events));

    stillCapturer?.addListener(notifyListeners);
    viewController.addListener(notifyListeners);
    eventSpeaker.addListener(notifyListeners);

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

    // performanceMonitors.add(
    //   PerformanceMonitor(length: _length, title: 'Metrics')
    //     ..sink.addStream(metricsComputer.stream),
    // );
    //
    // performanceMonitors.add(
    //   PerformanceMonitor(length: _length, title: 'Time Series')
    //     ..sink.addStream(timeSeriesAccumulator.stream),
    // );

    performanceMonitors.add(
      PerformanceMonitor(length: _length, title: 'Detector')
        ..sink.addStream(detector.stream),
    );

    tickEmitter.start();
  }
}
