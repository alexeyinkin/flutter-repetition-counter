import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../controllers/still.dart';

class AllowCameraWidget extends StatelessWidget {
  final StillCapturer stillCapturer;

  const AllowCameraWidget({required this.stillCapturer});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onPressed,
      child: const Center(
        child: Text(
          'Allow the Camera Access',
          style: TextStyle(color: Colors.white, fontSize: 32),
        ),
      ),
    );
  }

  Future<void> _onPressed() async {
    final status = await Permission.camera.status;

    switch (status) {
      case .granted:
      case .denied:
        await stillCapturer.setDefaultCamera();
      default: // ignore: no_default_cases
        await openAppSettings();
    }
  }
}
