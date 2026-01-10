import 'dart:async';

import 'package:meta/meta.dart';

import '../../models/analyzer_message.dart';
import '../../models/titled_timed_matrix.dart';
import '../analyzer.dart';

/// Detects repetitions and exercise changes.
abstract class AbstractDetector extends Analyzer<TitledTimedMatrix, void> {
  Stream<DetectorEvent> get events => _eventsController.stream;
  final _eventsController = StreamController<DetectorEvent>.broadcast();

  @protected
  void emit(DetectorEvent event) {
    _eventsController.add(event);
  }

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
  final int tick;

  const DetectorEvent({required this.tick});

  R accept<R>(DetectorEventVisitor<R> visitor);

  @override
  bool operator ==(Object other) {
    return other is DetectorEvent && tick == other.tick;
  }

  @override
  int get hashCode => Object.hashAll([tick]);
}

class ExerciseChangeEvent extends DetectorEvent {
  const ExerciseChangeEvent({required super.tick});

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
    required super.tick,
    required this.number,
  });

  @override
  R accept<R>(DetectorEventVisitor<R> visitor) =>
      visitor.visitRepetitionEvent(this);

  // Not overriding the comparison because we only need that for testing,
  // and tests use ExerciseChangeEvnet for simplicity.
}
