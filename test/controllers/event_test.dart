import 'package:repetition_counter/controllers/detectors/abstract.dart';
import 'package:repetition_counter/controllers/event.dart';
import 'package:test/test.dart';

final _dt = DateTime(0);

void main() {
  group('EventAccumulator', ()  {
    test('', () async {
      final obj = EventAccumulator(expireTicks: 10);

      obj.sink.add(ExerciseChangeEvent(dateTime: _dt, tick: 1));
      await Future.delayed(Duration.zero);

      expect(obj.events, [ExerciseChangeEvent(dateTime: _dt, tick: 1)]);

      obj.sink.add(ExerciseChangeEvent(dateTime: _dt, tick: 1));
      await Future.delayed(Duration.zero);

      expect(obj.events, [
        ExerciseChangeEvent(dateTime: _dt, tick: 1),
        ExerciseChangeEvent(dateTime: _dt, tick: 1),
      ]);

      obj.sink.add(ExerciseChangeEvent(dateTime: _dt, tick: 10));
      await Future.delayed(Duration.zero);

      expect(obj.events, [
        ExerciseChangeEvent(dateTime: _dt, tick: 10),
        ExerciseChangeEvent(dateTime: _dt, tick: 1),
        ExerciseChangeEvent(dateTime: _dt, tick: 1),
      ]);

      obj.sink.add(ExerciseChangeEvent(dateTime: _dt, tick: 11));
      await Future.delayed(Duration.zero);

      expect(obj.events, [
        ExerciseChangeEvent(dateTime: _dt, tick: 11),
        ExerciseChangeEvent(dateTime: _dt, tick: 10),
      ]);
    });
  });
}
