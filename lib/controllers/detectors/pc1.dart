import 'dart:async';
import 'dart:math' as math;

import 'package:collection/collection.dart';
import 'package:flutter/rendering.dart';

import '../../const.dart';
import '../../models/analyzer_message.dart';
import '../../models/titled_timed_matrix.dart';
import '../../painters/chart.dart';
import '../../painters/chart_stack.dart';
import '../../painters/eigenvalues.dart';
import '../../style.dart';
import '../../util/peak_detector.dart';
import '../event.dart';
import '../pca.dart';
import 'abstract.dart';

// How high PC 1 should rise to call a repetition.
const _threshold = .65;

// How low PC 1 should drop to separate repetitions.
const _resetThreshold = .35;

// How long PC 1 should stay below the threshold.
const _preThresholdTicks = 4;

// How long PC 1 should stay above the threshold.
const _preFireTicks = 3;

const _pcIndex = 0; // PC 1

// How far back we look for repetitions after detecting the exercise change.
const _ticksBehindExerciseChange = targetFps * 9; // TODO: use time

// How long we wait after the exercise change for the pattern to establish.
const _waitAfterExerciseChange = targetFps * 55 ~/ 10; // TODO: use time

// How far PC 1 should break out of the established range for exercise change.
const _rangeBreakFactor = 1.5;

// The established range is older than this many data points.
const _rangeBreakDelay = targetFps * 25 ~/ 10; // TODO: use time

/// Runs PCA and detects PC 1 oscillations.
class Pc1Detector extends AbstractDetector {
  PrincipalComponentAnalyzer get pca => _pca;
  final PrincipalComponentAnalyzer _pca;

  final _lastRepTicks = <int>[-1000];
  final _lastExerciseChangeTicks = <int>[-1000];

  double _lastThreshold = 0;
  double _lastResetThreshold = 0;
  int _lastStartAfterIndex = 0;
  int _lastRepetitionNumber = 0;

  Pc1Detector({required int dimensions, required int analyzeDataPoints})
    : _pca = PrincipalComponentAnalyzer(
        analyzeDataPoints: analyzeDataPoints,
        dimensions: dimensions,
        stabilizeSigns: {0},
      );

  @override
  Future<void> detect(AnalyzerMessage<TitledTimedMatrix> message) async {
    final pcaMessage = await _pca.processAndStore(message);
    if (pcaMessage != null) {
      _detect(pcaMessage);
    }
  }

  void _detect(AnalyzerMessage<TitledTimedMatrix> message) {
    if (message.data.rows[_pca.analyzeDataPoints].tick <= 0) {
      // Not enough data points accumulated.
      return;
    }

    final pc1 = message.data.getColumn(_pcIndex);
    final pc1Values = pc1.map((v) => v.$2).toList(growable: false);
    final max = pc1Values.max;
    final min = pc1Values.min;
    final variance = max - min;

    if (variance == 0) {
      return;
    }

    final tick = message.tick;
    final rbd = RangeBreakDetector(
      data: pc1Values.sublist(0, _pca.analyzeDataPoints + _rangeBreakDelay),
      delay: _rangeBreakDelay,
    );
    final rangeBreakFactor = rbd.factor;

    if (rangeBreakFactor > _rangeBreakFactor) {
      _lastExerciseChangeTicks.add(tick);
      _lastRepetitionNumber = 0;
      emit(ExerciseChangeEvent(dateTime: message.processedAt, tick: tick));
    }

    if (tick - _lastExerciseChangeTicks.last < _waitAfterExerciseChange) {
      return; // Wait for the pattern to establish.
    }

    final threshold = min + variance * _threshold;
    final resetThreshold = min + variance * _resetThreshold;
    final startAfterIndex = message.data.indexByTick(
      math.max(
        _lastRepTicks.last,
        _lastExerciseChangeTicks.last - _ticksBehindExerciseChange,
      ),
    );

    final peakDetector = PeakDetector(
      pc1Values,
      threshold: threshold,
      resetThreshold: resetThreshold,
      preThresholdTicks: _preThresholdTicks,
      preFireTicks: _preFireTicks,
      startAfterIndex: startAfterIndex,
    );

    final relativePeaks = peakDetector.detect();

    for (final relativePeak in relativePeaks) {
      final peak = message.data.rows[relativePeak].tick;
      _lastRepTicks.add(peak);
      emit(
        RepetitionEvent(
          dateTime: message.processedAt,
          tick: peak,
          number: ++_lastRepetitionNumber,
        ),
      );
    }

    // For the painter:
    _lastThreshold = threshold;
    _lastResetThreshold = resetThreshold;
    _lastStartAfterIndex = startAfterIndex;
  }

  @override
  List<CustomPainter> getPainters({
    required EventAccumulator eventAccumulator,
  }) => [
    ChartStackPainter(
      _pca,
      eventAccumulator: eventAccumulator,
      normalizedRect: const Rect.fromLTRB(2 / 3, .2, 1, 1),
      showWindowLabels: true,
      getChartOverlays: (int index) => switch (index) {
        _pcIndex => [
          ValueRangeOverlay(
            color: Colors.chartMarkup,
            max: _lastThreshold,
            min: _lastResetThreshold,
          ),
          TickGuideOverlay(
            color: Colors.chartMarkup,
            dataPointIndex: _pca.analyzeDataPoints,
            tick: 0,
          ),
          TickGuideOverlay(
            color: Colors.chartMarkup,
            dataPointIndex: _lastStartAfterIndex,
            tick: 0,
          ),
        ],
        _ => const [],
      },
    ),
    EigenvaluesPainter(_pca, normalizedRect: const Rect.fromLTRB(2 / 3, 0, 1, .2)),
  ];
}

/// Detects how far the recent values are out of the established range.
class RangeBreakDetector {
  /// Data points, from recent to oldest.
  final List<double> data;

  /// Data this old and older form the established range.
  final int delay; // TODO: use time

  const RangeBreakDetector({required this.data, required this.delay});

  /// The normalized excursion, > 1 if the recent data is out of the range.
  double get factor {
    final referenceData = data.sublist(delay);
    final referenceMax = referenceData.max;
    final referenceMin = referenceData.min;
    final referenceRange = referenceMax - referenceMin;

    if (referenceRange == 0) {
      return 0;
    }

    final testRange = data.sublist(0, delay);
    final testMax = testRange.max;
    final testMin = testRange.min;

    return math.max(
      (referenceMax - testMin) / referenceRange,
      (testMax - referenceMin) / referenceRange,
    );
  }
}
