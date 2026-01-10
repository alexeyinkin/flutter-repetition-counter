import 'dart:async';

import 'package:flutter/rendering.dart';
import 'package:meta/meta.dart';

import '../../models/analyzer_message.dart';
import '../../models/titled_timed_matrix.dart';
import '../../painters/compound.dart';
import '../../util/stream.dart';
import '../analyzer.dart';
import '../event.dart';

/// Detects repetitions and exercise changes.
abstract class AbstractDetector extends Analyzer<TitledTimedMatrix, void> {
  Stream<DetectorEvent> get events => _eventsController.stream;
  final _eventsController = StreamController<DetectorEvent>.broadcast();
  CompoundPainter? _painter;

  @protected
  void emit(DetectorEvent event) {
    _eventsController.add(event);
  }

  CustomPainter? getPainter({required EventAccumulator eventAccumulator}) {
    _painter = _painter ?? CompoundPainter(repaint: stream.listenable);
    _painter!.painters = getPainters(eventAccumulator: eventAccumulator);
    return _painter;
  }

  List<CustomPainter> getPainters({
    required EventAccumulator eventAccumulator,
  }) => const [];

  @override
  Future<Object> process(AnalyzerMessage<TitledTimedMatrix> message) async {
    await detect(message);
    return 1; // Can't return null because null drops the frame.
  }

  @protected
  Future<void> detect(AnalyzerMessage<TitledTimedMatrix> message);
}

abstract class DetectorEventVisitor<R> {
  const DetectorEventVisitor();

  R visit(DetectorEvent event) => event.accept(this);

  R visitExerciseChangeEvent(ExerciseChangeEvent event);

  R visitRepetitionEvent(RepetitionEvent event);
}

sealed class DetectorEvent {
  final DateTime dateTime;
  final int tick;

  const DetectorEvent({required this.dateTime, required this.tick});

  R accept<R>(DetectorEventVisitor<R> visitor);

  @override
  bool operator ==(Object other) {
    return other is DetectorEvent &&
        dateTime == other.dateTime &&
        tick == other.tick;
  }

  @override
  int get hashCode => Object.hashAll([tick]);
}

class ExerciseChangeEvent extends DetectorEvent {
  const ExerciseChangeEvent({required super.dateTime, required super.tick});

  @override
  R accept<R>(DetectorEventVisitor<R> visitor) =>
      visitor.visitExerciseChangeEvent(this);

  @override
  bool operator ==(Object other) {
    return other is ExerciseChangeEvent && super == other;
  }
}

class RepetitionEvent extends DetectorEvent {
  final int number;

  const RepetitionEvent({
    required super.dateTime,
    required super.tick,
    required this.number,
  });

  @override
  R accept<R>(DetectorEventVisitor<R> visitor) =>
      visitor.visitRepetitionEvent(this);

  // Not overriding the comparison because we only need that for testing,
  // and tests use ExerciseChangeEvnet for simplicity.
}
