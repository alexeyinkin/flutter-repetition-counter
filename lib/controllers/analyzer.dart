import 'dart:async';

import 'package:clock/clock.dart';
import 'package:meta/meta.dart';

import '../models/analyzer_message.dart';
import '../util/stream.dart';
import '../util/timed_awaiter.dart';
import 'message_emitter.dart';

abstract class Analyzer<Input, Output> extends MessageEmitter<Output> {
  StreamSink<AnalyzerMessage<Input>> get sink => _inputController.sink;
  final _inputController = StreamController<AnalyzerMessage<Input>>();

  @override
  Stream<AnalyzerMessage<Output>> get stream => _streamController.stream;
  final _streamController =
      StreamController<AnalyzerMessage<Output>>.broadcast();

  @override
  AnalyzerMessage<Output>? get lastMessage => _lastMessage;
  AnalyzerMessage<Output>? _lastMessage;

  Analyzer() {
    unawaited(
      _inputController.stream.conflateMap(_processAndStoreAndEmit).drain(),
    );
  }

  Future<void> _processAndStoreAndEmit(AnalyzerMessage<Input> message) async {
    final result = await processAndStore(message);
    if (result == null) {
      return;
    }
    _streamController.add(result);
  }

  Future<AnalyzerMessage<Output>?> processAndStore(
    AnalyzerMessage<Input> message,
  ) async {
    final pickedAt = clock.now();

    try {
      final awaiter = TimedAwaiter(() => process(message));
      final data = await awaiter.future;

      if (data == null) {
        return null;
      }

      return _lastMessage = message.withData(
        data,
        cpuDuration: awaiter.elapsed,
        pickedAt: pickedAt,
      );
      // ignore: avoid_catches_without_on_clauses
    } catch (ex) {
      print(ex); // ignore: avoid_print
      return null;
    }
  }

  @protected
  Future<Output?> process(AnalyzerMessage<Input> message);
}
