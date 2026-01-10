import 'package:repetition_counter/util/circular_buffer.dart';
import 'package:test/test.dart';

void main() {
  group('CircularBuffer', () {
    test('initialization preserves underlying list length', () {
      final source = [1, 2, 3];
      final buffer = CircularBuffer(source);

      expect(buffer.length, equals(3));
    });

    test('access logic treats index 0 as head', () {
      final source = [10, 20, 30];
      final buffer = CircularBuffer(source);

      expect(buffer.toList(), [10, 30, 20]);
    });

    group('add', () {
      test('add updates head and overwrites correctly', () {
        final source = [1, 2, 3];
        final buffer = CircularBuffer(source);

        expect(buffer.add(4), 2);
        expect(buffer.toList(), [4, 1, 3]);
        expect(source, [1, 4, 3]);
        //                 ^ head

        expect(buffer.add(5), 3);
        expect(buffer.toList(), [5, 4, 1]);
        expect(source, [1, 4, 5]);
        //                    ^ head
      });

      test('circular wrapping works correctly', () {
        final buffer = CircularBuffer([1, 2, 3]);

        expect(buffer.add(10), 2);
        expect(buffer.add(20), 3);
        expect(buffer.add(30), 1);

        expect(buffer.toList(), [30, 20, 10]);

        expect(buffer.add(40), 10);

        expect(buffer.toList(), [40, 30, 20]);
      });
    });

    group('removeLast', () {
      test('removeLast moves the head back, the deleted item stays', () {
        final buffer = CircularBuffer([1, 2, 3]);

        buffer.add(10);
        buffer.add(20);

        expect(buffer.toList(), [20, 10, 1]);

        final removed = buffer.removeLast();

        expect(removed, 20);
        expect(buffer.toList(), [10, 1, 20]);

        buffer.add(30);

        expect(buffer.toList(), [30, 10, 1]);
      });

      test('removeLast handles wrapping backwards', () {
        final source = [1, 2, 3];
        final buffer = CircularBuffer(source);

        final removed = buffer.removeLast();

        expect(removed, 1);
        expect(buffer.toList(), [3, 2, 1]);

        buffer.add(99);

        expect(buffer.toList(), [99, 3, 2]);
      });
    });

    test('shallowCopyList', (){
      final source = [1, 2, 3];
      final buffer = CircularBuffer(source);

      final e0 = buffer.shallowCopyList();
      buffer.add(4);

      expect(e0, [1, 3, 2]);
    });

    test('ofLists factory creates independent lists', () {
      final buffer = CircularBuffer.ofLists(3, 2, 9);

      expect(buffer.length, 3);
      expect(buffer[0].length, 2);
      expect(buffer[0], [9, 9]);

      buffer[0][0] = 5;
      expect(buffer[0][0], 5);
      expect(buffer[1][0], 9, reason: "Inner lists must be distinct instances");
    });

    group('Unsupported Operations', () {
      test('random write throws', () {
        final buffer = CircularBuffer([1, 2]);
        expect(() => buffer[0] = 5, throwsUnsupportedError);
      });

      test('setting length throws', () {
        final buffer = CircularBuffer([1, 2]);
        expect(() => buffer.length = 5, throwsUnsupportedError);
      });
    });

    test('integrates with ListBase methods', () {
      final buffer = CircularBuffer([0, 0, 0]);
      buffer.add(1);
      buffer.add(2);
      buffer.add(3);

      // buffer view: [3, 2, 1]

      expect(buffer.contains(2), isTrue);
      expect(buffer.indexOf(3), 0);
      expect(buffer.indexOf(1), 2);
      expect(buffer.where((i) => i > 1).toList(), [3, 2]);
    });
  });
}
