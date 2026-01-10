import 'package:repetition_counter/models/titled_timed_vector.dart';
import 'package:repetition_counter/util/iterable.dart';
import 'package:test/test.dart';

void main() {
  group('Iterables', () {
    test('semigraphicsToList', () {
      const chart = '''
*  *
 *- -
 **
''';

      final result = semigraphicsToList(chart);

      expect(result, [2.0, 1.0, 0.0, 2.0, 0.0]);
    });
  });
}
