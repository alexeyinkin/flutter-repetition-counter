import 'package:flutter/foundation.dart';

import '../enums/view_mode.dart';

/// Manages the view options.
class ViewController extends ChangeNotifier {
  ViewMode get mode => _mode;
  ViewMode _mode = .cameraSkeletonCharts;

  /// Rotates the view modes.
  void nextMode() {
    _mode = ViewMode.values[(_mode.index + 1) % ViewMode.values.length];
    print('New mode: $_mode'); // ignore: avoid_print
    notifyListeners();
  }
}
