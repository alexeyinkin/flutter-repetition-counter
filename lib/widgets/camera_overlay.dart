import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../controllers/app.dart';
import '../enums/view_mode.dart';
import '../painters/chart_stack.dart';
import '../painters/performance.dart';
import '../painters/pose.dart';
import '../painters/recent_events.dart';

class CameraOverlayWidget extends StatelessWidget {
  final AppController ac;

  const CameraOverlayWidget(this.ac);

  @override
  Widget build(BuildContext context) {
    final cc = ac.cameraController;

    return ListenableBuilder(
      listenable: ac.viewController,
      builder: (_, _) {
        return Stack(
          children: [
            if (cc != null) ...[
              ListenableBuilder(
                listenable: cc,
                builder: (_, _) => RepaintBoundary(child: CameraPreview(cc)),
              ),

              if (!ac.viewController.mode.shouldShowCamera)
                const Positioned.fill(child: ColoredBox(color: Colors.black)),
            ],

            if (ac.viewController.mode.shouldShowSkeleton)
              Positioned.fill(
                child: RepaintBoundary(
                  child: CustomPaint(painter: PosePainter(ac.poseDetector)),
                ),
              ),

            Positioned.fill(
              child: RepaintBoundary(
                child: CustomPaint(
                  painter: RecentEventsPainter(
                    ac.eventAccumulator,
                    tickEmitter: ac.tickEmitter,
                  ),
                ),
              ),
            ),

            if (ac.viewController.mode.shouldShowCharts) ...[
              Positioned.fill(
                child: RepaintBoundary(
                  child: CustomPaint(
                    painter: ChartStackPainter(
                      ac.timeSeriesAccumulator,
                      eventAccumulator: ac.eventAccumulator,
                      normalizedRect: const Rect.fromLTRB(0, 0, .33, 1),
                      showWindowLabels: false,
                    ),
                  ),
                ),
              ),

              Positioned.fill(
                child: RepaintBoundary(
                  child: CustomPaint(
                    painter: ac.detector.getPainter(
                      eventAccumulator: ac.eventAccumulator,
                    ),
                  ),
                ),
              ),

              Positioned.fill(
                child: RepaintBoundary(
                  child: CustomPaint(
                    painter: PerformancePainter(
                      ac.performanceMonitors,
                      normalizedRect: const Rect.fromLTRB(.35, 0, .65, .3),
                      tickEmitter: ac.tickEmitter,
                    ),
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

extension on ViewMode {
  bool get shouldShowCamera => switch (this) {
    .camera => true,
    .cameraSkeleton => true,
    .cameraSkeletonCharts => true,
    .skeletonCharts => false,
  };

  bool get shouldShowSkeleton => switch (this) {
    .camera => false,
    .cameraSkeleton => true,
    .cameraSkeletonCharts => true,
    .skeletonCharts => true,
  };

  bool get shouldShowCharts => switch (this) {
    .camera => false,
    .cameraSkeleton => false,
    .cameraSkeletonCharts => true,
    .skeletonCharts => true,
  };
}
