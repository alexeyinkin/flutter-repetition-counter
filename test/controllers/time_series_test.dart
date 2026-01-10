import 'package:repetition_counter/controllers/time_series.dart';
import 'package:repetition_counter/models/titled_timed_vector.dart';
import 'package:test/test.dart';

import 'util.dart';

void main() {
  group('TimeSeriesAccumulator', () {
    test('ok', () async {
      final obj = TimeSeriesAccumulator(length: 3, vectorLength: 2);
      String getTitle(int n) => n.toString();

      final r1 = await obj.process(
        am(1, data: TitledTimedVector([1, 2], getTitle: getTitle, tick: 1)),
      );

      expect(r1.rows.length, 3);
      expect(r1.rows[0].values, [1.0, 2.0]);
      expect(r1.rows[1].values, [.0, .0]);
      expect(r1.rows[2].values, [.0, .0]);
      expect(r1.getTitle(0), '0');
      expect(r1.getTitle(1), '1');

      final r2 = await obj.process(
        am(1, data: TitledTimedVector([3, 4], getTitle: getTitle, tick: 1)),
      );

      expect(r2.rows.length, 3);
      expect(r2.rows[0].values, [3.0, 4.0]);
      expect(r2.rows[1].values, [1.0, 2.0]);
      expect(r2.rows[2].values, [.0, .0]);

      final r3 = await obj.process(
        am(1, data: TitledTimedVector([5, 6], getTitle: getTitle, tick: 1)),
      );

      expect(r3.rows.length, 3);
      expect(r3.rows[0].values, [5.0, 6.0]);
      expect(r3.rows[1].values, [3.0, 4.0]);
      expect(r3.rows[2].values, [1.0, 2.0]);

      final r4 = await obj.process(
        am(1, data: TitledTimedVector([7, 8], getTitle: getTitle, tick: 1)),
      );

      expect(r4.rows.length, 3);
      expect(r4.rows[0].values, [7.0, 8.0]);
      expect(r4.rows[1].values, [5.0, 6.0]);
      expect(r4.rows[2].values, [3.0, 4.0]);
    });

    test('keeps the tick in a row', () async {
      final obj = TimeSeriesAccumulator(length: 3, vectorLength: 2);
      String getTitle(int n) => n.toString();

      final r1 = await obj.process(
        am(7, data: TitledTimedVector([1, 2], getTitle: getTitle, tick: 7)),
      );

      expect(r1.rows[0].tick, 7);
      expect(r1.rows[1].tick, 0);
      expect(r1.rows[2].tick, 0);
    });

    test('returns a copy of the buffer', () async {
      final obj = TimeSeriesAccumulator(length: 2, vectorLength: 1);
      String getTitle(int n) => n.toString();

      final r1 = await obj.process(
        am(1, data: TitledTimedVector([1], getTitle: getTitle, tick: 1)),
      );
      await obj.process(
        am(1, data: TitledTimedVector([2], getTitle: getTitle, tick: 1)),
      );

      expect(r1.rows[0].values, [1.0]);
      expect(r1.rows[1].values, [0.0]);
    });
  });
}
