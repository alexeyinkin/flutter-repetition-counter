import 'dart:async';

import 'detectors/abstract.dart';

class EventAccumulator {
  final int expireTicks;

  StreamSink get sink => _inputController.sink;
  final _inputController = StreamController<DetectorEvent>();

  /// New to old.
  List<DetectorEvent> get events => List.unmodifiable(_events);
  final _events = <DetectorEvent>[];

  EventAccumulator({required this.expireTicks}) {
    _inputController.stream.listen(_add);
  }

  void _add(DetectorEvent event) {
    int deleteTick = event.tick - expireTicks;
    _events.insert(0, event);

    for (int i = 1; i < _events.length; i++) {
      if (events[i].tick <= deleteTick) {
        _events.removeRange(i, _events.length);
        break;
      }
    }
  }
}
