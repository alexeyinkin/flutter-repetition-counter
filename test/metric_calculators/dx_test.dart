import 'package:flutter_mediapipe_vision/flutter_mediapipe_vision.dart';
import 'package:repetition_counter/metric_calculators/dx.dart';
import 'package:test/test.dart';

import 'util.dart';

void main() {
  group('DxCalculator', () {
    test('positive difference, aspect ratio 1', () {
      final calculator = DxCalculator(0, 1, title: '');

      final pose = [nl(0.0, 0.0), nl(1.0, 0.0)];

      final result = calculator.calculate(pose, 1.0);
      expect(result, closeTo(1.0, 0.0001));
    });

    test('negative difference, aspect ratio 1', () {
      final calculator = DxCalculator(0, 1, title: '');

      final pose = [nl(1.0, 0.0), nl(0.0, 0.0)];

      final result = calculator.calculate(pose, 1.0);
      expect(result, closeTo(-1.0, 0.0001));
    });

    test('zero difference, aspect ratio 1', () {
      final calculator = DxCalculator(0, 1, title: '');

      final pose = [nl(0.0, 0.0), nl(0.0, 0.0)];

      final result = calculator.calculate(pose, 1.0);
      expect(result, closeTo(0.0, 0.0001));
    });

    test('positive difference, aspect ratio 2', () {
      final calculator = DxCalculator(0, 1, title: '');

      final pose = [nl(0.0, 0.0), nl(1.0, 0.0)];

      final result = calculator.calculate(pose, 2.0);
      expect(result, closeTo(2.0, 0.0001));
    });

    test('difference with varying y, aspect ratio 2', () {
      final calculator = DxCalculator(0, 1, title: '');

      final pose = [nl(0.0, 1.0), nl(1.0, -1.0)];

      final result = calculator.calculate(pose, 2.0);
      expect(result, closeTo(2.0, 0.0001));
    });
  });
}
