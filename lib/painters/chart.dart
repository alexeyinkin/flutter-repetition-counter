import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

import '../style.dart';

const _relativePadding = .1;

class ChartPainter extends CustomPainter {
  final List<(int, double)> dataPoints;
  final double maxAbs;
  final Rect rect;
  final String title;

  ChartPainter(
    this.dataPoints, {
    required this.maxAbs,
    required this.rect,
    required this.title,
  });

  @override
  void paint(Canvas canvas, Size size) {
    double indexToX(int i) => 1 - i / dataPoints.length;

    double valueToY(double v) =>
        -v / (maxAbs + .0001) / (1 + _relativePadding) / 2 + .5;

    final overlays = <ChartOverlay>[
      LineChartSeriesOverlay(dataPoints),
      TitleOverlay(title),
    ];

    final painter = ChartOverlayPainter(
      canvas: canvas,
      indexToX: indexToX,
      rect: rect,
      valueToY: valueToY,
    );

    for (final overlay in overlays) {
      painter.visit(overlay);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

abstract class ChartOverlayVisitor<R> {
  const ChartOverlayVisitor();

  R visit(ChartOverlay overlay) => overlay.accept(this);

  R visitLineChartSeries(LineChartSeriesOverlay overlay);

  R visitTitle(TitleOverlay overlay);
}

class ChartOverlayPainter extends ChartOverlayVisitor<void> {
  final Canvas canvas;
  final double Function(int) indexToX;
  final Rect rect;
  final double Function(double) valueToY;

  const ChartOverlayPainter({
    required this.canvas,
    required this.indexToX,
    required this.rect,
    required this.valueToY,
  });

  @override
  void visitLineChartSeries(LineChartSeriesOverlay overlay) {
    final length = overlay.dataPoints.length;

    final points = List.filled(length, Offset.zero, growable: false);

    for (final indexed in overlay.dataPoints.indexed) {
      final t = indexed.$1;
      final x = indexToX(t);

      final tickAndValue = indexed.$2;
      final y = valueToY(tickAndValue.$2);

      points[t] = Offset(
        rect.left + x * rect.width,
        rect.top + y * rect.height,
      );
    }

    canvas.drawPoints(ui.PointMode.polygon, points, Paints.chartLine);
  }

  @override
  void visitTitle(TitleOverlay overlay) {
    final pb = ui.ParagraphBuilder(ParagraphStyles.alignLeft);
    pb.pushStyle(TextStyles.chartTitle);
    pb.addText(overlay.title);
    final p = pb.build();
    p.layout(ui.ParagraphConstraints(width: rect.width));
    canvas.drawParagraph(
      p,
      Offset(rect.left, rect.top + rect.height / 2 - p.height / 2),
    );
  }
}

sealed class ChartOverlay {
  const ChartOverlay();

  R accept<R>(ChartOverlayVisitor<R> visitor);
}

class LineChartSeriesOverlay extends ChartOverlay {
  final Iterable<(int, double)> dataPoints;

  const LineChartSeriesOverlay(this.dataPoints);

  @override
  R accept<R>(ChartOverlayVisitor<R> visitor) =>
      visitor.visitLineChartSeries(this);
}

class TitleOverlay extends ChartOverlay {
  final String title;

  const TitleOverlay(this.title);

  @override
  R accept<R>(ChartOverlayVisitor<R> visitor) => visitor.visitTitle(this);
}
