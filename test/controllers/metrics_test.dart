import 'package:repetition_counter/controllers/metrics.dart';
import 'package:repetition_counter/metric_calculators/dx.dart';
import 'package:repetition_counter/metric_calculators/dy.dart';
import 'package:repetition_counter/models/pose.dart';
import 'package:test/test.dart';

import '../metric_calculators/util.dart';
import 'util.dart';

void main() {
  group('MetricsComputer', () {
    test('ok', () async {
      final obj = MetricsComputer(
        metricCalculators: [
          DxCalculator(0, 1, title: 'calc1'),
          DyCalculator(1, 2, title: 'calc2'),
        ],
      );
      final message = Pose(
        aspectRatio: 2.5,
        landmarks: [nl(0, 0), nl(1, 2), nl(-2, -1)],
      );

      final result = await obj.process(am(1, data: message));

      expect(result.values, [2.5, -3.0]);
      expect(result.getTitle(0), 'calc1');
      expect(result.getTitle(1), 'calc2');
    });
  });
}
