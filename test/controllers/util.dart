import 'package:repetition_counter/models/analyzer_message.dart';

final _dt = DateTime(2000);

AnalyzerMessage am1(int tick, {int pr = 0}) => AnalyzerMessage(
  data: 1,
  pickedAt: _dt,
  processedAt: DateTime(2000, 1, 1, 0, 0, 0, pr),
  tick: tick,
);

AnalyzerMessage<T> am<T>(int tick, {required T data, int pr = 0}) =>
    AnalyzerMessage(
      data: data,
      pickedAt: _dt,
      processedAt: DateTime(2000, 1, 1, 0, 0, 0, pr),
      tick: tick,
    );
