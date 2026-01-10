import 'dart:async';

/// Times the CPU time of the [callback] run.
class TimedAwaiter<T> {
  final Future<T> Function() callback;
  final Stopwatch _stopwatch = Stopwatch();
  final Completer<T> _completer = Completer<T>();

  Duration get elapsed => _stopwatch.elapsed;

  Future<T> get future => _completer.future;

  TimedAwaiter(this.callback) {
    unawaited(_run());
  }

  Future<void> _run() async {
    int nesting = 0;

    void handleEnter(ZoneDelegate parent, Zone zone) {
      nesting++;
      if (nesting == 1) _stopwatch.start();
    }

    void handleExit(ZoneDelegate parent, Zone zone) {
      nesting--;
      if (nesting == 0) _stopwatch.stop();
    }

    final spec = ZoneSpecification(
      run: <R>(self, parent, zone, f) {
        handleEnter(parent, zone);
        try {
          return parent.run(zone, f);
        } finally {
          handleExit(parent, zone);
        }
      },
      runUnary: <R, A>(self, parent, zone, f, arg) {
        handleEnter(parent, zone);
        try {
          return parent.runUnary(zone, f, arg);
        } finally {
          handleExit(parent, zone);
        }
      },
      runBinary: <R, A1, A2>(self, parent, zone, f, arg1, arg2) {
        handleEnter(parent, zone);
        try {
          return parent.runBinary(zone, f, arg1, arg2);
        } finally {
          handleExit(parent, zone);
        }
      },
    );

    await runZoned(() async {
      try {
        final result = await callback();
        _completer.complete(result);
      } catch (e, s) {
        _completer.completeError(e, s);
      }
    }, zoneSpecification: spec);
  }
}
