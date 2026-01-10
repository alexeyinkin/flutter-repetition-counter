import 'package:repetition_counter/controllers/pca.dart';
import 'package:repetition_counter/models/titled_timed_matrix.dart';
import 'package:repetition_counter/models/titled_timed_vector.dart';
import 'package:test/test.dart';

import 'util.dart';

String _getTitle(i) => '';

void main() {
  group('PrincipalComponentAnalyzer', () {
    test('2D with single-axis variance to 1D', () async {
      final input = TitledTimedMatrix([
        TitledTimedVector([2.0, 10.0], getTitle: _getTitle, tick: 1),
        TitledTimedVector([4.0, 10.0], getTitle: _getTitle, tick: 3),
        TitledTimedVector([6.0, 10.0], getTitle: _getTitle, tick: 5),
      ], getTitle: _getTitle);

      // Keep 1 dimension, use all data to calculate
      final pca = PrincipalComponentAnalyzer(dimensions: 1, analyzeDataPoints: 3, stabilizeSigns: {});
      final result = await pca.process(am(1, data: input));

      // 1. Check dimensions
      expect(result?.rows.length, 3);
      expect(result!.rows.first.values.length, 1);

      // 2. Verify values
      // The mean of input X is 4.0.
      // Centered input X: [-2, 0, 2].
      // Output should preserve this relative distance of 2.0.
      // Note: We use .abs() because eigenvectors can flip sign (-2 vs 2).

      final p1 = result.rows[0].values[0];
      final p2 = result.rows[1].values[0];
      final p3 = result.rows[2].values[0];

      // The middle point (the mean) should be 0 in PCA space
      expect(p2, closeTo(0.0, 0.001));

      // The distance between points should be preserved (2.0 units)
      expect((p2 - p1).abs(), closeTo(2.0, 0.001));
      expect((p3 - p2).abs(), closeTo(2.0, 0.001));
    });

    /// Test Case 2: The "analyzeLength" Logic Check
    /// Goal: Ensure the transformation matrix is calculated ONLY using the start of the list.
    /// Input:
    ///   - Items 0-2: Perfect correlation on X-axis (Horizontal line).
    ///   - Item 3: Massive outlier on Y-axis.
    /// Logic: If analyzeLength is 3, PCA "learns" that only X matters.
    /// It should project the outlier onto the X-axis and completely ignore the huge Y value.
    test('ignore tail', () async {
      final input = TitledTimedMatrix([
        TitledTimedVector([10.0, 1.0], getTitle: _getTitle, tick: 1),
        TitledTimedVector([20.0, 1.0], getTitle: _getTitle, tick: 3),
        TitledTimedVector([30.0, 1.0], getTitle: _getTitle, tick: 5),
        TitledTimedVector([30.0, 9999.0], getTitle: _getTitle, tick: 7),
      ], getTitle: _getTitle);

      final pca = PrincipalComponentAnalyzer(dimensions: 1, analyzeDataPoints: 3, stabilizeSigns: {});
      final result = await pca.process(am(1, data: input));

      // If PCA worked correctly on the first 3 items, the Principal Component is Vector(1, 0).
      // Projecting [30, 9999] onto Vector(1, 0) results in just X component.
      // Therefore, Result[3] should be identical to Result[3].

      expect(result, isNotNull);
      expect(
          result!.rows[3].values[0],
          closeTo(result.rows[2].values[0], 0.001),
          reason: "The massive Y value should be ignored because PCA was trained only on X-axis data."
      );
    });

    /// Test Case 3: Diagonal Line (Correlation Check)
    /// Goal: Verify it handles correlated data (x = y).
    /// Input: Points on a perfect diagonal [1,1], [2,2], [3,3].
    /// Logic: The distance between [1,1] and [2,2] is sqrt(2) ≈ 1.414.
    /// The PCA 1D projection should reflect this Euclidean distance.
    test('projects diagonal data preserving euclidean distance', () async {
      final input = TitledTimedMatrix([
        TitledTimedVector([1.0, 1.0], getTitle: _getTitle, tick: 1),
        TitledTimedVector([2.0, 2.0], getTitle: _getTitle, tick: 3),
        TitledTimedVector([3.0, 3.0], getTitle: _getTitle, tick: 5),
      ], getTitle: _getTitle);

      final pca = PrincipalComponentAnalyzer(dimensions: 1, analyzeDataPoints: 3, stabilizeSigns: {});
      final result = await pca.process(am(1, data: input));

      expect(result, isNotNull);
      final val1 = result!.rows[0].values[0];
      final val2 = result.rows[1].values[0];

      // Distance between (1,1) and (2,2) is sqrt(1^2 + 1^2) = 1.4142...
      // The PCA projection onto the diagonal should equal this distance.
      expect((val2 - val1).abs(), closeTo(1.4142, 0.001));
    });

    /// Test Case 4: Zero Variance / Constant Input
    /// Goal: Ensure it doesn't crash on flat data.
    test('handles constant data gracefully (zero variance)', () async {
      final input = TitledTimedMatrix([
        TitledTimedVector([5.0, 5.0], getTitle: _getTitle, tick: 1),
        TitledTimedVector([5.0, 5.0], getTitle: _getTitle, tick: 3),
        TitledTimedVector([5.0, 5.0], getTitle: _getTitle, tick: 5),
      ], getTitle: _getTitle);

      final pca = PrincipalComponentAnalyzer(dimensions: 1, analyzeDataPoints: 3, stabilizeSigns: {});
      final result = await pca.process(am(1, data: input));

      // Should return 0.0 for all, as there is no deviation from mean.
      expect(result?.rows[0].values[0], closeTo(0.0, 0.001));
      expect(result?.rows[1].values[0], closeTo(0.0, 0.001));
    });
  });
}
