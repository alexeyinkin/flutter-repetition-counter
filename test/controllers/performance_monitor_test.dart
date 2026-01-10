import 'dart:async';

import 'package:repetition_counter/controllers/performance_monitor.dart';
import 'package:test/test.dart';

import 'util.dart';

void main() {
  group('PerformanceMonitor', () {
    test('initially empty', () {
      final obj = PerformanceMonitor(length: 3, title: '');
      expect(obj.messages, [null, null, null]);
    });

    group('add', () {
      test('arranges messages by ticks', () async {
        final messages = [am1(0), am1(1), am1(2), am1(4), am1(7)];
        final obj = PerformanceMonitor(length: 9, title: '');

        messages.forEach(obj.sink.add);
        await Future.delayed(Duration.zero);

        expect(obj.messages.length, 9);

        expect(obj.messages[0]?.tick, 7);
        expect(obj.messages[1], null);
        expect(obj.messages[2], null);
        expect(obj.messages[3]?.tick, 4);
        expect(obj.messages[4], null);
        expect(obj.messages[5]?.tick, 2);
        expect(obj.messages[6]?.tick, 1);
        expect(obj.messages[7]?.tick, 0);
        expect(obj.messages[8], null);
      });

      test('wraps', () async {
        final messages = [am1(0), am1(1), am1(2), am1(4), am1(7)];
        final obj = PerformanceMonitor(length: 6, title: '');

        messages.forEach(obj.sink.add);
        await Future.delayed(Duration.zero);

        expect(obj.messages.length, 6);

        expect(obj.messages[0]?.tick, 7);
        expect(obj.messages[1], null);
        expect(obj.messages[2], null);
        expect(obj.messages[3]?.tick, 4);
        expect(obj.messages[4], null);
        expect(obj.messages[5]?.tick, 2);
      });

      test('throws when adding an older message', () {
        final obj = PerformanceMonitor(length: 3, title: '');

        obj.add(am1(1));

        expect(() => obj.add(am1(0)), throwsArgumentError);
      });

      test('throws when adding a duplicate message', () {
        final obj = PerformanceMonitor(length: 3, title: '');

        obj.add(am1(1));

        expect(() => obj.add(am1(1)), throwsArgumentError);
      });
    });

    group('maxDuration', () {
      test('initially zero', () {
        final obj = PerformanceMonitor(length: 3, title: '');
        expect(obj.maxDuration, Duration.zero);
      });

      test('is max', () {
        final obj = PerformanceMonitor(length: 3, title: '');

        obj.add(am1(0, ms: 10));
        expect(obj.maxDuration, Duration(milliseconds: 10));

        obj.add(am1(1, ms: 3));
        expect(obj.maxDuration, Duration(milliseconds: 10));

        obj.add(am1(2, ms: 4));
        expect(obj.maxDuration, Duration(milliseconds: 10));

        obj.add(am1(3, ms: 1));
        expect(obj.maxDuration, Duration(milliseconds: 4));
      });
    });

    test('title', () {
      final obj = PerformanceMonitor(length: 1, title: 'abc');

      expect(obj.title, 'abc');
    });

    test('averageDuration', () {
      final obj = PerformanceMonitor(length: 3, title: '');
      expect(obj.averageDuration, Duration.zero);

      // Add 6 ms
      obj.add(am1(0, ms: 6));
      expect(obj.averageDuration, Duration(milliseconds: 6));

      // Null
      // Add 12 ms
      obj.add(am1(2, ms: 12));
      expect(obj.averageDuration, Duration(milliseconds: 9));

      // Replace 6 ms with 18 ms
      obj.add(am1(3, ms: 18));
      expect(obj.averageDuration, Duration(milliseconds: 15));

      // Replace Null with 24 ms
      obj.add(am1(4, ms: 24));
      expect(obj.averageDuration, Duration(milliseconds: 18));

      // Replace 12 ms with Null
      // Replace 18 ms with 30 ms
      obj.add(am1(6, ms: 30));
      expect(obj.averageDuration, Duration(milliseconds: 27));

      // Replace 24 ms with Null
      // Replace Null with Null
      // Replace 30 ms with 33 ms
      obj.add(am1(9, ms: 33));
      expect(obj.averageDuration, Duration(milliseconds: 33));
    });

    test('density', () {
      final obj = PerformanceMonitor(length: 4, title: '');
      expect(obj.density, 0.0);

      obj.add(am1(0));
      expect(obj.density, 1.0);

      obj.add(am1(2));
      expect(obj.density, 2 / 3);

      obj.add(am1(3));
      expect(obj.density, .75);

      // Replace 0 with 4
      obj.add(am1(4));
      expect(obj.density, .75);

      // Replace 1 [Null] with 5
      obj.add(am1(5));
      expect(obj.density, 1.0);

      // Replace 2 with 6 [Null]
      // Replace 3 with 7
      obj.add(am1(7));
      expect(obj.density, .75);
    });

    test('fps', () {
      final obj = PerformanceMonitor(length: 3, title: '');
      expect(obj.fps, 0.0);

      // Zero before the first full second after the first message.
      obj.add(am1(7, pr: 100));
      expect(obj.fps, 0.0);

      obj.add(am1(11, pr: 300));
      expect(obj.fps, 0.0);

      obj.add(am1(13, pr: 1099));
      expect(obj.fps, 0.0);

      obj.add(am1(17, pr: 1100));
      expect(obj.fps, 3.0);

      // No change until a full second after the last change.
      obj.add(am1(19, pr: 2099));
      expect(obj.fps, 3.0);

      // Change a full second after the last change.
      obj.add(am1(23, pr: 2100));
      expect(obj.fps, 2.0);

      // Divide by more than a second if more elapsed.
      obj.add(am1(29, pr: 3099));
      expect(obj.fps, 2.0);

      obj.add(am1(31, pr: 3700));
      expect(obj.fps, 1.25); // 2 in 1600 ms

      // Break a second in one hop.
      obj.add(am1(37, pr: 5700));
      expect(obj.fps, .5); // 1 in 2000 ms
    });
  });
}
