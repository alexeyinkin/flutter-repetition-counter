import 'dart:async';
import 'dart:collection';
import 'dart:math';

import '../models/analyzer_message.dart';
import '../util/circular_buffer.dart';

class PerformanceMonitor {
  final int length;
  final String title;

  StreamSink<AnalyzerMessage> get sink => _inputController.sink;
  final _inputController = StreamController<AnalyzerMessage>(sync: true);

  List<AnalyzerMessage?> get messages => UnmodifiableListView(_messages);
  final CircularBuffer<AnalyzerMessage?> _messages;

  int _latestTick = -1;

  Duration get maxDuration => _maxDuration;
  Duration _maxDuration = Duration.zero;
  int _maxDurationTick = -1;

  Duration get averageDuration =>
      _nonNullCount == 0 ? Duration.zero : _totalDuration ~/ _nonNullCount;
  Duration _totalDuration = Duration.zero;

  double get density => _latestTick == -1
      ? 0
      : _nonNullCount / min(_latestTick + 1, _messages.length);
  int _nonNullCount = 0;

  double get fps => _fps;
  double _fps = 0;
  DateTime? _lastSecondMessageProcessedAt;
  int _messagesSinceFpsReset = 0;

  PerformanceMonitor({required this.length, required this.title})
    : _messages = CircularBuffer(
        List<AnalyzerMessage?>.filled(length, null, growable: false),
      ) {
    _inputController.stream.listen(add);
  }

  void add(AnalyzerMessage message) {
    final tick = message.tick;

    if (tick <= _latestTick) {
      throw ArgumentError('Message out of order: $tick after $_latestTick');
    }

    final duration = message.cpuDuration;

    for (int i = _latestTick + 1; i < tick; i++) {
      final old = _messages.add(null);
      if (old != null) {
        _totalDuration -= old.cpuDuration;
        _nonNullCount--;
      }
    }

    _latestTick = tick;
    final old = _messages.add(message);
    _totalDuration += message.cpuDuration - (old?.cpuDuration ?? Duration.zero);
    if (old == null) {
      _nonNullCount++;
    }

    if (duration > _maxDuration) {
      _maxDuration = duration;
      _maxDurationTick = tick;
    } else if (tick - _maxDurationTick >= _messages.length) {
      _calculateMaxDuration();
    }

    if (_lastSecondMessageProcessedAt == null) {
      _lastSecondMessageProcessedAt = message.processedAt;
    } else {
      final millisecondsDiff = message.processedAt
          .difference(_lastSecondMessageProcessedAt!)
          .inMilliseconds;
      if (millisecondsDiff < 1000) {
        _messagesSinceFpsReset++;
      } else {
        _fps = (_messagesSinceFpsReset + 1) / millisecondsDiff * 1000;
        _messagesSinceFpsReset = 0;
        _lastSecondMessageProcessedAt = message.processedAt;
      }
    }
  }

  void _calculateMaxDuration() {
    Duration maxDuration = Duration.zero;
    AnalyzerMessage? longestMessage;

    for (final message in _messages.nonNulls) {
      final duration = message.cpuDuration;
      if (duration > maxDuration) {
        maxDuration = duration;
        longestMessage = message;
      }
    }

    _maxDuration = maxDuration;
    _maxDurationTick = longestMessage?.tick ?? 0;
  }
}
