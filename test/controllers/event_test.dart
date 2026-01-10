import 'package:repetition_counter/controllers/detectors/abstract.dart';
import 'package:repetition_counter/controllers/event.dart';
import 'package:test/test.dart';

void main() {
  group('EventAccumulator', ()  {
    test('', () async {
      final obj = EventAccumulator(expireTicks: 10);

      obj.sink.add(ExerciseChangeEvent(tick: 1));
      await Future.delayed(Duration.zero);

      expect(obj.events, [ExerciseChangeEvent(tick: 1)]);

      obj.sink.add(ExerciseChangeEvent(tick: 1));
      await Future.delayed(Duration.zero);

      expect(obj.events, [
        ExerciseChangeEvent(tick: 1),
        ExerciseChangeEvent(tick: 1),
      ]);

      obj.sink.add(ExerciseChangeEvent(tick: 10));
      await Future.delayed(Duration.zero);

      expect(obj.events, [
        ExerciseChangeEvent(tick: 10),
        ExerciseChangeEvent(tick: 1),
        ExerciseChangeEvent(tick: 1),
      ]);

      obj.sink.add(ExerciseChangeEvent(tick: 11));
      await Future.delayed(Duration.zero);

      expect(obj.events, [
        ExerciseChangeEvent(tick: 11),
        ExerciseChangeEvent(tick: 10),
      ]);
    });
  });
}
