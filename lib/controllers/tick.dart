import 'dart:async';

import 'package:clock/clock.dart';

import '../models/analyzer_message.dart';
import 'message_emitter.dart';

class TickEmitter implements MessageEmitter<void> {
  @override
  Stream<AnalyzerMessage<void>> get stream => _streamController.stream;
  final _streamController = StreamController<AnalyzerMessage<void>>.broadcast();

  bool _isRunning = false;
  int _nextTick = 0;
  DateTime _lastEmitted = DateTime(0);

  @override
  AnalyzerMessage<void>? get lastMessage => _lastMessage;
  AnalyzerMessage<void>? _lastMessage;

  final Duration step;

  TickEmitter(this.step);

  void start() {
    if (_isRunning) {
      return;
    }

    _isRunning = true;
    unawaited(_loop());
  }

  Future<void> _loop() async {
    while (true) {
      final now = clock.now();

      final elapsed = now.difference(_lastEmitted);
      final left = step - elapsed;

      if (left <= Duration.zero) {
        _lastEmitted = now;
      } else {
        await Future.delayed(left);
        _lastEmitted = now.add(left);
      }

      if (!_isRunning) {
        break;
      }

      _lastMessage = AnalyzerMessage<void>(
        data: null,
        pickedAt: _lastEmitted,
        processedAt: _lastEmitted,
        tick: _nextTick++,
      );
      _streamController.add(_lastMessage!);
    }
  }

  void stop() {
    _isRunning = false;
  }
}
