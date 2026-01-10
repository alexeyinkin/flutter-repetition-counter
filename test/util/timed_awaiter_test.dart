import 'dart:async';

import 'package:repetition_counter/util/timed_awaiter.dart';
import 'package:test/test.dart';

/// Blocks the CPU for roughly [duration].
///
/// We cannot use Future.delayed here because we want to measure
/// actual execution time (CPU usage), not waiting time.
void _blockCpuFor(Duration duration) {
  final stopwatch = Stopwatch()..start();
  while (stopwatch.elapsed < duration) {
    // Busy loop
  }
}

void main() {
  group('TimedAwaiter', () {
    test('measures synchronous CPU work accurately', () async {
      final workDuration = const Duration(milliseconds: 50);

      final awaiter = TimedAwaiter(() async {
        _blockCpuFor(workDuration);
        return true;
      });

      await awaiter.future;

      // Allow a small margin of error for test overhead
      expect(
        awaiter.elapsed.inMilliseconds,
        greaterThanOrEqualTo(workDuration.inMilliseconds),
      );
    });

    test('ignores scheduled latency (Future.delayed)', () async {
      final delayDuration = const Duration(milliseconds: 200);

      final awaiter = TimedAwaiter(() async {
        // This is pure "waiting" time. The Zone should exit here.
        await Future.delayed(delayDuration);
        return true;
      });

      await awaiter.future;

      // The actual work done was effectively 0ms.
      // The elapsed time should be extremely small, definitely not 200ms.
      print('Elapsed time for pure delay: ${awaiter.elapsed.inMilliseconds}ms');
      expect(awaiter.elapsed.inMilliseconds, lessThan(20));
    });

    test('measures mixed Work -> Wait -> Work correctly', () async {
      final work1 = const Duration(milliseconds: 50);
      final wait = const Duration(milliseconds: 200);
      final work2 = const Duration(milliseconds: 50);

      final totalWallClockStopwatch = Stopwatch()..start();

      final awaiter = TimedAwaiter(() async {
        _blockCpuFor(work1); //        Should count
        await Future.delayed(wait); // Should NOT count
        _blockCpuFor(work2); //        Should count
        return true;
      });

      await awaiter.future;
      totalWallClockStopwatch.stop();

      final totalCpuWork = work1 + work2;

      print('Wall Clock: ${totalWallClockStopwatch.elapsedMilliseconds}ms');
      print('TimedAwaiter Elapsed: ${awaiter.elapsed.inMilliseconds}ms');

      expect(
        awaiter.elapsed.inMilliseconds,
        greaterThanOrEqualTo(totalCpuWork.inMilliseconds),
      );

      expect(
        awaiter.elapsed.inMilliseconds,
        lessThan(totalWallClockStopwatch.elapsedMilliseconds - 100),
      );
    });

    test('handles errors correctly', () async {
      final awaiter = TimedAwaiter(() async {
        _blockCpuFor(const Duration(milliseconds: 20));
        throw Exception('Boom');
      });

      try {
        await awaiter.future;
        fail('Should have thrown');
      } catch (e) {
        expect(e.toString(), contains('Boom'));
      }

      // Even if it crashed, it should have measured the work done before the crash
      expect(awaiter.elapsed.inMilliseconds, greaterThanOrEqualTo(20));
    });
  });
}
