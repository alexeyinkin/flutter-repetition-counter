import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:native_device_orientation/native_device_orientation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/analyzer_message.dart';
import '../models/still.dart';
import '../util/iterable.dart';
import 'analyzer.dart';

const _cameraKey = 'camera';

abstract class StillCapturer extends Analyzer<void, Still> with ChangeNotifier {
  final SharedPreferencesWithCache _pref;
  CameraController? _cameraController;

  CameraController? get cameraController => _cameraController;

  StillCapturerState _state = .closed;
  NativeDeviceOrientation _orientation = .portraitUp;

  StillCapturer(this._pref) {
    setDefaultCamera();
    _checkDenial();
    _initDeviceOrientation();
  }

  factory StillCapturer.create(SharedPreferencesWithCache pref) =>
      kIsWeb ? TakePictureCapturer(pref) : ImageStreamCapturer(pref);

  void _initDeviceOrientation() {
    if (kIsWeb) {
      return;
    }

    if (Platform.isAndroid) {
      NativeDeviceOrientationCommunicator().onOrientationChanged().listen(
        _onOrientationChanged,
      );
    }
  }

  void _onOrientationChanged(NativeDeviceOrientation newValue) {
    _orientation = newValue;
  }

  int _getNeedsClockwiseQuarterTurns() =>
      ((_cameraController?.description.sensorOrientation ?? 0) ~/ 90 +
          _getClockwiseQuarterTurnsToPortraitUp()) %
      4;

  int _getClockwiseQuarterTurnsToPortraitUp() => switch (_orientation) {
    .portraitUp => 0,
    .landscapeLeft => 1,
    .portraitDown => 2,
    .landscapeRight => 3,
    .unknown => 0,
  };

  Future<void> _checkDenial() async {
    if (_state == .denied) {
      final status = await Permission.camera.status;

      switch (status) {
        case .granted:
          await setDefaultCamera();
        case .denied:
          if (!await Permission.camera.shouldShowRequestRationale) {
            await setDefaultCamera();
          }
        default: // ignore: no_default_cases
          break;
      }
    }

    Timer(const Duration(seconds: 1), _checkDenial);
  }

  Future<void> setDefaultCamera() async {
    final direction =
        CameraLensDirection.values.byNameOrNull(_pref.getString(_cameraKey)) ??
        .front;

    try {
      final cameras = await getAvailableCameras();
      final camera =
          cameras.firstWhereOrNull((c) => c.lensDirection == direction) ??
          cameras.first;

      await setCameraDescription(camera);
      // ignore: avoid_catches_without_on_clauses
    } catch (ex) {
      // Web does not allow listing without permissions.
      _setState(.denied);
    }
  }

  Future<void> nextCamera() async {
    final cd = _cameraController?.description;
    final cameras = await getAvailableCameras();

    if (cd == null) {
      await setCameraDescription(cameras.first);
      return;
    }

    await setCameraDescription(
      cameras[(cameras.indexOf(cd) + 1) % cameras.length],
    );
  }

  Future<List<CameraDescription>> getAvailableCameras() => availableCameras();

  Future<void> setCameraDescription(CameraDescription description) async {
    if (_state == .changing) {
      return;
    }
    _setState(.changing);
    unawaited(_pref.setString(_cameraKey, description.lensDirection.name));
    await _cameraController?.dispose();

    _cameraController = CameraController(
      description,
      ResolutionPreset.low,
      enableAudio: false,
    );

    try {
      await _cameraController!.initialize();
      _setState(.open);
    } on CameraException catch (ex) {
      // Android allows listing but not init without permission.
      // Codes: https://github.com/flutter/flutter/issues/69298
      if (ex.code == 'CameraAccessDenied') {
        _setState(.denied);
      } else {
        _setState(.closed);
      }
      print(ex); // ignore: avoid_print
      // ignore: avoid_catches_without_on_clauses
    } catch (ex) {
      _setState(.closed);
      print(ex); // ignore: avoid_print
    }
  }

  void _setState(StillCapturerState state) {
    if (state == _state) {
      return;
    }

    _state = state;
    notifyListeners();
  }

  bool get isCameraDenied => _state == .denied;

  bool get isPreviewAvailable => _state == .open;

  bool get _needsHorizontalFlipping =>
      !kIsWeb &&
      _cameraController?.description.lensDirection == CameraLensDirection.front;
}

class TakePictureCapturer extends StillCapturer {
  TakePictureCapturer(super._pref);

  @override
  Future<Still?> process(AnalyzerMessage<void> m) async {
    if (_state != .open) {
      return null;
    }

    final cc = _cameraController!;

    try {
      final file = await cc.takePicture();
      final bytes = await file.readAsBytes();
      return EncodedStill(
        aspectRatio: cc.value.aspectRatio,
        needsClockwiseQuarterTurns: _getNeedsClockwiseQuarterTurns(),
        needsHorizontalFlipping: _needsHorizontalFlipping,
        bytes: bytes,
      );
      // ignore: avoid_catches_without_on_clauses
    } catch (ex) {
      print(ex); // ignore: avoid_print
      return null;
    }
  }
}

class ImageStreamCapturer extends StillCapturer {
  Completer<Still?> _pendingRequest = Completer();
  Timer? _stopTimer;
  bool _isStreaming = false;
  final _idleTimeout = const Duration(seconds: 5);

  ImageStreamCapturer(super._pref);

  @override
  Future<void> setCameraDescription(CameraDescription description) async {
    await _stopStreaming();
    await super.setCameraDescription(description);
  }

  @override
  Future<Still?> process(AnalyzerMessage<void> m) async {
    if (_state != .open) {
      return null;
    }

    _completeNullIfNot();
    _pendingRequest = Completer<Still?>();

    _stopTimer?.cancel();
    _stopTimer = Timer(_idleTimeout, _stopStreaming);

    if (!_isStreaming) {
      try {
        _setState(.changing);
        await _cameraController!.startImageStream(_onFrameCaptured);
        _isStreaming = true;
        _setState(.open);
        // ignore: avoid_catches_without_on_clauses
      } catch (ex) {
        try {
          unawaited(_cameraController?.dispose());
          // ignore: avoid_catches_without_on_clauses
        } catch (ex) {
          print(ex); // ignore: avoid_print
        }
        _setState(.closed);
        _completeNullIfNot();
        print(ex); // ignore: avoid_print
      }
    }

    return _pendingRequest.future;
  }

  void _completeNullIfNot() {
    if (!_pendingRequest.isCompleted) {
      _pendingRequest.complete(null);
    }
  }

  void _onFrameCaptured(CameraImage image) {
    if (_pendingRequest.isCompleted) {
      return;
    }

    final still = PlanesStill(
      aspectRatio: _cameraController?.value.aspectRatio ?? 1,
      needsClockwiseQuarterTurns: _getNeedsClockwiseQuarterTurns(),
      needsHorizontalFlipping: _needsHorizontalFlipping,
      planes: image.planes.map((plane) => plane.bytes).toList(growable: false),
      width: image.width,
      height: image.height,
    );

    _pendingRequest.complete(still);
  }

  Future<void> _stopStreaming() async {
    final oldState = _state;
    _setState(.changing);
    _completeNullIfNot();

    if (_isStreaming) {
      _isStreaming = false;
      await _cameraController?.stopImageStream();
      _completeNullIfNot();
    }
    _setState(oldState);
  }
}

enum StillCapturerState { closed, open, changing, denied }
