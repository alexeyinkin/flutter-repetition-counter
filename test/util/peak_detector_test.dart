import 'dart:math' as math;

import 'package:repetition_counter/util/iterable.dart';
import 'package:repetition_counter/util/peak_detector.dart';
import 'package:test/test.dart';

class Buffers {
  //                        / didn't go below reset
  //                  / didn't have 3 ticks above
  //          / didn't have 4 ticks below
  //  / check                      / check     / check
  static final a = semigraphicsToList('''
*********     ***   * **    ***    ***        ****     *
--------------------------------------------------------
         **      * * *  **            *    **     ****
           **             *    ****    *  *  
--------------------------------------------------------
             *    *        *            **   *        *
''');
}

void main() {
  group('PeakDetector.', () {
    test('Nothing on empty', () {
      final obj = PeakDetector(
        const [],
        threshold: 1,
        resetThreshold: 0,
        preThresholdTicks: 0,
        preFireTicks: 0,
        startAfterIndex: 0,
      );

      final peaks = obj.detect();

      expect(peaks, isEmpty);
    });

    test('Nothing on flat', () {
      final obj = PeakDetector(
        List<double>.filled(1000, 7),
        threshold: 1,
        resetThreshold: 0,
        preThresholdTicks: 0,
        preFireTicks: 0,
        startAfterIndex: 1000,
      );

      final peaks = obj.detect();

      expect(peaks, isEmpty);
    });


    group('Detects peaks.', () {
      test('Started above thresholds', () {
        final obj = PeakDetector(
          Buffers.a,
          threshold: 4,
          resetThreshold: 1,
          preThresholdTicks: 4,
          preFireTicks: 3,
          startAfterIndex: Buffers.a.length,
        );

        final peaks = obj.detect();

        expect(peaks, [47, 35, 6]);
      });

      test('Started below thresholds', () {
        final obj = PeakDetector(
          Buffers.a,
          threshold: 4,
          resetThreshold: 1,
          preThresholdTicks: 4,
          preFireTicks: 3,
          startAfterIndex: Buffers.a.length - 1,
        );

        final peaks = obj.detect();

        expect(peaks, [47, 35, 6]);
      });

      test('Started between thresholds', () {
        final obj = PeakDetector(
          Buffers.a,
          threshold: 4,
          resetThreshold: 1,
          preThresholdTicks: 4,
          preFireTicks: 3,
          startAfterIndex: Buffers.a.length - 2,
        );

        final peaks = obj.detect();

        expect(peaks, [35, 6]);
      });

      test('startAfter beyond the length throws', () {
        final obj = PeakDetector(
          List<double>.filled(100, 7),
          threshold: 1,
          resetThreshold: 0,
          preThresholdTicks: 0,
          preFireTicks: 0,
          startAfterIndex: 101,
        );

        expect(() => obj.detect(), throwsRangeError);
      });
    });
  });
}
