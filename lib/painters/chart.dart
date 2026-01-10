import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

import '../style.dart';

const _relativePadding = .1;

class ChartPainter extends CustomPainter {
  final List<(int, double)> dataPoints;
  final double maxAbs;
  final List<ChartOverlay> overlays;
  final Rect rect;
  final SeriesType seriesType;
  final bool showWindowLabels;
  final String title;
  final XScaleMode xScaleMode;
  final YRangeMode yRangeMode;

  ChartPainter(
    this.dataPoints, {
    required this.maxAbs,
    required this.overlays,
    required this.rect,
    required this.seriesType,
    required this.showWindowLabels,
    required this.title,
    required this.xScaleMode,
    required this.yRangeMode,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final latestTick = dataPoints.firstOrNull?.$1 ?? 0;
    final oldestTick = dataPoints.lastOrNull?.$1 ?? 0;
    final tickSpan = latestTick - oldestTick + .00001;

    double tickToX(int tick) => (tick - oldestTick) / tickSpan;
    double indexToX(int i) => 1 - i / dataPoints.length;

    final valueToY = switch (yRangeMode) {
      .negativeMaxToMax =>
        (double v) => -v / (maxAbs + .0001) / (1 + _relativePadding) / 2 + .5,
      .zeroToMax =>
        (double v) => 1 - v / (maxAbs + .0001) / (1 + _relativePadding),
    };

    final effectiveOverlays = <ChartOverlay>[
      switch (seriesType) {
        .columns => ColumnsChartSeriesOverlay(dataPoints),
        .line => LineChartSeriesOverlay(dataPoints),
      },
      ...overlays,
      TitleOverlay(title),
      if (showWindowLabels) ...[
        ValueLabelOverlay(color: Colors.chart, value: maxAbs, precision: 3),
        if (yRangeMode == .negativeMaxToMax)
          ValueLabelOverlay(color: Colors.chart, value: -maxAbs, precision: 3),
      ],
    ];

    final painter = ChartOverlayPainter(
      canvas: canvas,
      indexToX: indexToX,
      rect: rect,
      tickToX: tickToX,
      valueToY: valueToY,
      xScaleMode: xScaleMode,
    );

    for (final overlay in effectiveOverlays) {
      painter.visit(overlay);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

abstract class ChartOverlayVisitor<R> {
  const ChartOverlayVisitor();

  R visit(ChartOverlay overlay) => overlay.accept(this);

  R visitColumnsChartSeries(ColumnsChartSeriesOverlay overlay);

  R visitLineChartSeries(LineChartSeriesOverlay overlay);

  R visitTickGuide(TickGuideOverlay overlay);

  R visitTitle(TitleOverlay overlay);

  R visitValueGuide(ValueGuideOverlay overlay);

  R visitValueLabel(ValueLabelOverlay overlay);
}

class ChartOverlayPainter extends ChartOverlayVisitor<void> {
  final Canvas canvas;
  final double Function(int) indexToX;
  final Rect rect;
  final double Function(int) tickToX;
  final double Function(double) valueToY;
  final XScaleMode xScaleMode;

  const ChartOverlayPainter({
    required this.canvas,
    required this.indexToX,
    required this.rect,
    required this.tickToX,
    required this.valueToY,
    required this.xScaleMode,
  });

  @override
  void visitColumnsChartSeries(ColumnsChartSeriesOverlay overlay) {
    final length = overlay.dataPoints.length;

    final points = List.filled(length * 2, Offset.zero);

    for (final indexed in overlay.dataPoints.indexed) {
      final t = indexed.$1;
      final x = _indexedDataPointToX(indexed);

      final tickAndValue = indexed.$2;
      final y = valueToY(tickAndValue.$2);

      final offsetX = rect.left + x * rect.width;
      points[t * 2] = Offset(offsetX, rect.top + y * rect.height);
      points[t * 2 + 1] = Offset(offsetX, rect.top + valueToY(0) * rect.height);
    }

    canvas.drawPoints(ui.PointMode.lines, points, Paints.chartColumn);
  }

  @override
  void visitLineChartSeries(LineChartSeriesOverlay overlay) {
    final length = overlay.dataPoints.length;

    final points = List.filled(length, Offset.zero, growable: false);

    for (final indexed in overlay.dataPoints.indexed) {
      final t = indexed.$1;
      final x = _indexedDataPointToX(indexed);

      final tickAndValue = indexed.$2;
      final y = valueToY(tickAndValue.$2);

      points[t] = Offset(
        rect.left + x * rect.width,
        rect.top + y * rect.height,
      );
    }

    canvas.drawPoints(ui.PointMode.polygon, points, Paints.chartLine);
  }

  double _indexedDataPointToX((int, (int, double)) indexedDataPoint) =>
      switch (xScaleMode) {
        .dataPoints => indexToX(indexedDataPoint.$1),
        .ticks => tickToX(indexedDataPoint.$2.$1),
      };

  @override
  void visitTickGuide(TickGuideOverlay overlay) {
    final paint = Paint()
      ..color = overlay.color
      ..strokeWidth = 2
      ..style = .fill;

    final x = switch (xScaleMode) {
      .dataPoints => indexToX(overlay.dataPointIndex),
      .ticks => tickToX(overlay.tick),
    };
    final canvasX = rect.left + x * rect.width;

    canvas.drawLine(
      Offset(canvasX, rect.top),
      Offset(canvasX, rect.bottom),
      paint,
    );
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

  @override
  void visitValueGuide(ValueGuideOverlay overlay) {
    final paint = Paint()
      ..color = overlay.color
      ..strokeWidth = 2
      ..style = .fill;

    final y = rect.top + valueToY(overlay.value) * rect.height;

    canvas.drawLine(Offset(rect.left, y), Offset(rect.right, y), paint);
  }

  @override
  void visitValueLabel(ValueLabelOverlay overlay) {
    final y = valueToY(overlay.value);

    final pb = ui.ParagraphBuilder(ParagraphStyles.alignLeft);
    pb.pushStyle(TextStyles.chartLabel);
    pb.addText(overlay.value.toStringAsPrecision(overlay.precision));
    final p = pb.build();
    p.layout(ui.ParagraphConstraints(width: rect.width));
    canvas.drawParagraph(
      p,
      Offset(rect.left, rect.top + y * rect.height - p.height / 2),
    );
  }
}

sealed class ChartOverlay {
  const ChartOverlay();

  R accept<R>(ChartOverlayVisitor<R> visitor);
}

class ColumnsChartSeriesOverlay extends ChartOverlay {
  final Iterable<(int, double)> dataPoints;

  const ColumnsChartSeriesOverlay(this.dataPoints);

  @override
  R accept<R>(ChartOverlayVisitor<R> visitor) =>
      visitor.visitColumnsChartSeries(this);
}

class LineChartSeriesOverlay extends ChartOverlay {
  final Iterable<(int, double)> dataPoints;

  const LineChartSeriesOverlay(this.dataPoints);

  @override
  R accept<R>(ChartOverlayVisitor<R> visitor) =>
      visitor.visitLineChartSeries(this);
}

class TickGuideOverlay extends ChartOverlay {
  final Color color;
  final int dataPointIndex;
  final int tick;

  const TickGuideOverlay({
    required this.color,
    required this.dataPointIndex,
    required this.tick,
  });

  @override
  R accept<R>(ChartOverlayVisitor<R> visitor) => visitor.visitTickGuide(this);
}

class TitleOverlay extends ChartOverlay {
  final String title;

  const TitleOverlay(this.title);

  @override
  R accept<R>(ChartOverlayVisitor<R> visitor) => visitor.visitTitle(this);
}

class ValueGuideOverlay extends ChartOverlay {
  final Color color;
  final double value;

  const ValueGuideOverlay({required this.color, required this.value});

  @override
  R accept<R>(ChartOverlayVisitor<R> visitor) => visitor.visitValueGuide(this);
}

class ValueLabelOverlay extends ChartOverlay {
  final Color color;
  final double value;
  final int precision;

  const ValueLabelOverlay({
    required this.color,
    required this.value,
    required this.precision,
  });

  @override
  R accept<R>(ChartOverlayVisitor visitor) => visitor.visitValueLabel(this);
}

enum SeriesType { columns, line }

enum XScaleMode { ticks, dataPoints }

enum YRangeMode { negativeMaxToMax, zeroToMax }
