import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../controllers/app.dart';
import '../painters/chart_stack.dart';
import '../painters/pose.dart';

class CameraOverlayWidget extends StatelessWidget {
  final AppController ac;

  const CameraOverlayWidget(this.ac);

  @override
  Widget build(BuildContext context) {
    final cc = ac.cameraController;

    return Stack(
      children: [
        ListenableBuilder(
          listenable: cc,
          builder: (_, _) => RepaintBoundary(child: CameraPreview(cc)),
        ),

        Positioned.fill(
          child: RepaintBoundary(
            child: CustomPaint(painter: PosePainter(ac.poseDetector)),
          ),
        ),

        Positioned.fill(
          child: RepaintBoundary(
            child: CustomPaint(
              painter: ChartStackPainter(
                ac.timeSeriesAccumulator,
                normalizedRect: const Rect.fromLTRB(0, 0, .33, 1),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
