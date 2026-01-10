import 'dart:collection';

import 'performance_monitor.dart';

class PerformanceMonitors {
  int get length => _monitors.length;

  List<PerformanceMonitor> get monitors => UnmodifiableListView(_monitors);
  final _monitors = <PerformanceMonitor>[];

  void add(PerformanceMonitor monitor) {
    for (final obj in _monitors) {
      if (obj.length != monitor.length) {
        throw ArgumentError(
          "This monitor's length is ${monitor.length}. "
          "Already having a monitor of ${obj.length}.",
        );
      }
    }

    _monitors.add(monitor);
  }
}
