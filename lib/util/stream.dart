import 'dart:async';

import 'package:flutter/foundation.dart';

extension StreamExtension<T> on Stream<T> {
  Listenable get listenable => _StreamToListenable(this);

  /// Processes events one by one using [convert].
  ///
  /// If [convert] is busy processing an event, new events are held in a
  /// single-slot buffer. If multiple events arrive while busy, only the
  /// most recent one is kept (others are dropped).
  Stream<R> conflateMap<R>(Future<R> Function(T event) convert) {
    var controller = StreamController<R>();
    StreamSubscription<T>? subscription;
    bool isProcessing = false;
    bool hasPending = false;
    T? pendingEvent;

    void process() {
      if (!hasPending || isProcessing || controller.isClosed) return;

      isProcessing = true;
      final currentEvent = pendingEvent as T;
      hasPending = false;
      pendingEvent = null;

      // Execute the async operation
      convert(currentEvent).then((result) {
        if (!controller.isClosed) controller.add(result);
      }).catchError((Object error, StackTrace stackTrace) {
        if (!controller.isClosed) controller.addError(error, stackTrace);
      }).whenComplete(() {
        isProcessing = false;
        // Check if a new event arrived while we were working
        if (hasPending) {
          process();
        } else if (subscription!.isPaused) {
          // Resume if we have no work and upstream was paused
          subscription!.resume();
        }
      });
    }

    controller.onListen = () {
      subscription = this.listen(
        (event) {
          pendingEvent = event;
          hasPending = true;
          process();
        },
        onError: controller.addError,
        onDone: () async {
          // Wait for current processing to finish before closing
          while (isProcessing || hasPending) {
            await Future.delayed(Duration.zero);
          }
          await controller.close();
        },
      );
    };

    controller.onCancel = () {
      subscription?.cancel();
    };

    return controller.stream;
  }
}

class _StreamToListenable<T> with ChangeNotifier {
  StreamSubscription<T>? _subscription;

  _StreamToListenable(Stream<T> stream) {
    _subscription = stream.listen(
      (value) {
        notifyListeners();
      },
      onError: (error) {
        notifyListeners();
      },
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
