import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../enums/view_mode.dart';
import '../util/iterable.dart';

const _modeKey = 'viewMode';

/// Manages the view options.
class ViewController extends ChangeNotifier {
  final SharedPreferencesWithCache _pref;
  ViewMode _mode;

  ViewController(this._pref)
    : _mode =
          ViewMode.values.byNameOrNull(_pref.getString(_modeKey)) ??
          .cameraSkeletonCharts;

  ViewMode get mode => _mode;

  set mode(ViewMode newValue) {
    if (_mode == newValue) {
      return;
    }

    unawaited(_pref.setString(_modeKey, newValue.name));
    _mode = newValue;
    print('New mode: $_mode'); // ignore: avoid_print
    notifyListeners();
  }

  /// Rotates the view modes.
  void nextMode() {
    mode = ViewMode.values[(_mode.index + 1) % ViewMode.values.length];
  }
}
