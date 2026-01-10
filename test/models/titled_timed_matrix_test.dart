import 'package:repetition_counter/models/titled_timed_matrix.dart';
import 'package:repetition_counter/models/titled_timed_vector.dart';
import 'package:test/test.dart';

String _getTitle(int i) => '';

void main() {
  group('TitledTimedMatrix', () {
    group('getColumn', () {
      test('OK', () {
        final obj = TitledTimedMatrix([
          TitledTimedVector([1, 2], getTitle: _getTitle, tick: 1),
          TitledTimedVector([3, 4], getTitle: _getTitle, tick: 2),
        ], getTitle: _getTitle);

        final result = obj.getColumn(1);

        expect(result, [(1, 2.0), (2, 4.0)]);
      });

      test('Throws if not enough in a row', () {
        final obj = TitledTimedMatrix([
          TitledTimedVector([1, 2], getTitle: _getTitle, tick: 1),
          TitledTimedVector([3, 4], getTitle: _getTitle, tick: 2),
          TitledTimedVector([5], getTitle: _getTitle, tick: 3),
        ], getTitle: _getTitle);

        expect(() => obj.getColumn(1), throwsRangeError);
      });
    });
  });
}
