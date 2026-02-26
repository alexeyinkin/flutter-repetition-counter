import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../controllers/app.dart';
import '../enums/view_mode.dart';
import 'my_toggle_buttons.dart';

const _padding = 50.0;
const _closeTimeout = Duration(seconds: 5);

class SettingsScreen extends StatefulWidget {
  final AppController appController;
  final VoidCallback closeCallback;

  const SettingsScreen({
    required this.appController,
    required this.closeCallback,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Timer? _closeTimer;
  List<CameraDescription>? _cameras;

  @override
  void initState() {
    super.initState();
    unawaited(_init());
  }

  Future<void> _init() async {
    _resetCloseTimer();
    _cameras =
        await widget.appController.stillCapturer?.getAvailableCameras() ?? [];
    setState(() {});
  }

  void _resetCloseTimer() {
    _closeTimer?.cancel();
    _closeTimer = Timer(_closeTimeout, widget.closeCallback);
  }

  @override
  Widget build(BuildContext context) {
    final vc = widget.appController.viewController;
    final es = widget.appController.eventSpeaker;
    final s = widget.appController.stillCapturer;

    return GestureDetector(
      onTap: widget.closeCallback,
      child: ColoredBox(
        color: const Color(0xB0000000),
        child: Padding(
          padding: const EdgeInsets.all(_padding),
          child: ListenableBuilder(
            listenable: widget.appController,
            builder: (context, _) {
              if (!_isLoaded()) {
                return const SizedBox.expand();
              }

              final cd = s?.cameraController?.description;
              final cameras = _cameras!;

              return LayoutBuilder(
                builder: (context, constraints) {
                  return Column(
                    spacing: _padding,
                    children: [
                      Expanded(
                        child: MyToggleButtons(
                          isSelected: ViewMode.values
                              .map((v) => v == vc.mode)
                              .toList(growable: false),
                          children: ViewMode.values
                              .map((v) => Text(_getViewModeTitle(v)))
                              .toList(growable: false),
                          onPressed: (n) => _setViewMode(.values[n]),
                        ),
                      ),
                      if (cameras.length > 1)
                        Expanded(
                          child: MyToggleButtons(
                            isSelected: cameras
                                .map((c) => c == cd)
                                .toList(growable: false),
                            children: cameras
                                .map((c) => Text(_getCameraTitle(c)))
                                .toList(growable: false),
                            onPressed: (n) => _setCamera(cameras[n]),
                          ),
                        ),
                      Expanded(
                        child: MyToggleButtons(
                          isSelected: [es.isMute, !es.isMute],
                          children: const [
                            Icon(Icons.volume_off),
                            Icon(Icons.volume_up),
                          ],
                          onPressed: (n) => _setIsMute(n == 0),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  bool _isLoaded() => _cameras != null;

  void _setViewMode(ViewMode newValue) {
    widget.appController.viewController.mode = newValue;
    _resetCloseTimer();
  }

  void _setIsMute(bool newValue) {
    widget.appController.eventSpeaker.isMute = newValue;
    _resetCloseTimer();
  }

  Future<void> _setCamera(CameraDescription camera) async {
    _resetCloseTimer();
    await widget.appController.stillCapturer?.setCameraDescription(camera);
    _resetCloseTimer();
  }

  String _getViewModeTitle(ViewMode mode) => switch (mode) {
    .camera => 'Camera Only',
    .cameraSkeleton => 'Camera\nSilhouette',
    .cameraSkeletonCharts => 'Camera\nSilhouette\nCharts',
    .skeletonCharts => 'Silhouette\nCharts',
  };

  String _getCameraTitle(CameraDescription c) => switch (c.lensDirection) {
    .back => 'Back Camera',
    .front => 'Front Camera',
    .external => 'External Camera',
  };
}
