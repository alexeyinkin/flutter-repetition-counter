/// Detects peaks on the [data].
///
/// The most recent points are at the beginning of the [data].
/// Starts counting from [startAfterIndex] and iterates towards the beginning.
/// To pronounce a peak, the value should be below [threshold]
/// for at least [preThresholdTicks], during which hit [resetThreshold]
/// at least momentarily, then go above [threshold] and stay above it
/// for at least [preFireTicks].
class PeakDetector {
  final List<double> data;
  final double threshold;
  final double resetThreshold;
  final int preThresholdTicks; // TODO: Use time
  final int preFireTicks; // TODO: Use time
  final int startAfterIndex;

  PeakDetector(
    this.data, {
    required this.threshold,
    required this.resetThreshold,
    required this.preThresholdTicks,
    required this.preFireTicks,
    required this.startAfterIndex,
  });

  /// Detects the peaks, returns the list of ticks where peaks were detected.
  List<int> detect() {
    final result = <int>[];
    bool beenBelowReset = false;
    int ticksBelowThresholdLastTime = 0;
    int ticksBelowThresholdThisTime = 0;
    int ticksAboveThreshold = 0;

    // Zero is the most recent, so start from the end and count to zero.
    for (int tick = startAfterIndex; --tick >= 0;) {
      final v = data[tick];

      if (v < resetThreshold) {
        beenBelowReset = true;
      }
      if (v < threshold) {
        ticksBelowThresholdThisTime++;
        ticksAboveThreshold = 0;
      } else {
        ticksAboveThreshold++;
        if (ticksBelowThresholdThisTime > 0) {
          ticksBelowThresholdLastTime = ticksBelowThresholdThisTime;
          ticksBelowThresholdThisTime = 0;
        }
      }

      if (beenBelowReset &&
          ticksAboveThreshold >= preFireTicks &&
          ticksBelowThresholdLastTime >= preThresholdTicks) {
        result.add(tick);
        beenBelowReset = false;
      }
    }

    return result;
  }
}
