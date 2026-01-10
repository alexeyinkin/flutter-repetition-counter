import 'package:repetition_counter/models/analyzer_message.dart';

final _dt = DateTime(2000);

AnalyzerMessage am1(int tick, {int ms = 0, int pr = 0}) => AnalyzerMessage(
  cpuDuration: Duration(milliseconds: ms),
  data: 1,
  pickedAt: _dt,
  processedAt: DateTime(2000, 1, 1, 0, 0, 0, pr),
  tick: tick,
);

AnalyzerMessage<T> am<T>(int tick, {required T data, int ms = 0, int pr = 0}) =>
    AnalyzerMessage(
      cpuDuration: Duration(milliseconds: ms),
      data: data,
      pickedAt: _dt,
      processedAt: DateTime(2000, 1, 1, 0, 0, 0, pr),
      tick: tick,
    );
