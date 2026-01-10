import 'package:clock/clock.dart';
import 'package:meta/meta.dart';

@immutable
class AnalyzerMessage<T> {
  final Duration cpuDuration;
  final T data;
  final DateTime pickedAt;
  final DateTime processedAt;
  final int tick;

  const AnalyzerMessage({
    required this.cpuDuration,
    required this.data,
    required this.pickedAt,
    required this.processedAt,
    required this.tick,
  });

  AnalyzerMessage<Output> withData<Output>(
    Output data, {
    required Duration cpuDuration,
    required DateTime pickedAt,
  }) => AnalyzerMessage<Output>(
    cpuDuration: cpuDuration,
    data: data,
    pickedAt: pickedAt,
    processedAt: clock.now(),
    tick: tick,
  );

  @override
  bool operator ==(Object other) {
    if (other is! AnalyzerMessage) return false;
    return cpuDuration == cpuDuration &&
        data == other.data &&
        pickedAt == other.pickedAt &&
        processedAt == other.processedAt &&
        tick == other.tick;
  }

  @override
  int get hashCode =>
      Object.hashAll([cpuDuration, data, pickedAt, processedAt, tick]);

  @override
  String toString() => '$tick, $pickedAt -> $processedAt, $data';
}
