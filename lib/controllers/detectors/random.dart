import 'dart:math';
import 'dart:ui';

import '../../models/analyzer_message.dart';
import '../../models/titled_timed_matrix.dart';
import 'abstract.dart';

// A trivial fake detector for testing the event painters and speakers.
class RandomDetector extends AbstractDetector {
  final random = Random();
  int _lastRepetitionNumber = 0;

  @override
  Future<void> detect(AnalyzerMessage<TitledTimedMatrix> message) async {
    if (random.nextDouble() < .03) {
      _lastRepetitionNumber = 0;
      emit(ExerciseChangeEvent(dateTime: message.processedAt, tick: message.tick));
    } else if (random.nextDouble() < .1) {
      emit(
        RepetitionEvent(
          dateTime: message.processedAt,
          number: ++_lastRepetitionNumber,
          tick: message.tick,
        ),
      );
    }
  }
}
