import 'dart:ui' as ui;

import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';

import '../controllers/message_emitter.dart';
import '../controllers/performance_monitors.dart';
import '../style.dart';
import '../util/rect.dart';
import '../util/stream.dart';
import 'chart.dart';

const _metricWidth = 50;
const _metricsWidth = _metricWidth * 3;

class PerformancePainter extends CustomPainter {
  final PerformanceMonitors performanceMonitors;
  final Rect normalizedRect;
  final MessageEmitter<void> tickEmitter;

  PerformancePainter(
    this.performanceMonitors, {
    required this.normalizedRect,
    required this.tickEmitter,
  }) : super(repaint: tickEmitter.stream.listenable);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = normalizedRect.timesSize(size);

    final chartRect = Rect.fromLTWH(
      rect.left,
      rect.top,
      rect.width - _metricsWidth,
      rect.height,
    );

    final h = chartRect.height / performanceMonitors.length;
    final maxMilliseconds = performanceMonitors.monitors
        .map((monitor) => monitor.maxDuration.inMilliseconds)
        .max
        .toDouble();

    double lastDensity = 1;
    for (final indexed in performanceMonitors.monitors.indexed) {
      final i = indexed.$1;
      final monitor = indexed.$2;
      final painter = ChartPainter(
        monitor.messages
            .mapIndexed(
              (i, m) => (i, m?.cpuDuration.inMilliseconds.toDouble() ?? 0),
            )
            .toList(growable: false),
        maxAbs: maxMilliseconds,
        overlays: const [ValueGuideOverlay(color: Colors.chart, value: .0)],
        rect: Rect.fromLTWH(
          chartRect.left,
          chartRect.top + i * h,
          chartRect.width,
          h,
        ),
        seriesType: .columns,
        showWindowLabels: true,
        title: monitor.title,
        xScaleMode: .ticks,
        yRangeMode: .zeroToMax,
      );
      painter.paint(canvas, size);

      double _paintMetricValue(String value, int index) {
        final pb = ui.ParagraphBuilder(ParagraphStyles.alignRight);
        pb.pushStyle(TextStyles.chartTitle);
        pb.addText(value);
        final p = pb.build();
        p.layout(ui.ParagraphConstraints(width: 300));
        canvas.drawParagraph(
          p,
          Offset(
            chartRect.right + 3 + (index + .5) * _metricWidth - p.width,
            chartRect.top + i * h + (h - p.height) / 2,
          ),
        );
        return p.height;
      }

      void _paintMetricUnits(String units, int index, double valueHeight) {
        final pb = ui.ParagraphBuilder(ParagraphStyles.alignLeft);
        pb.pushStyle(TextStyles.chartLabel);
        pb.addText(units);
        final p = pb.build();
        p.layout(ui.ParagraphConstraints(width: 300));
        canvas.drawParagraph(
          p,
          Offset(
            chartRect.right + 3 + (index + .5) * _metricWidth,
            chartRect.top + i * h + h - (h - valueHeight) / 2 - p.height,
          ),
        );
      }

      void _paintMetric(String value, String units, int index) {
        final valueHeight = _paintMetricValue(value, index);
        _paintMetricUnits(units, index, valueHeight);
      }

      _paintMetric(monitor.averageDuration.inMilliseconds.toString(), 'ms', 0);

      final density = monitor.density;
      final densityPreservation = density / lastDensity;
      lastDensity = density;

      _paintMetric(monitor.fps.toStringAsFixed(1), 'fps', 1);
      _paintMetric(
        ((1 - densityPreservation) * 100).toStringAsFixed(0),
        '%\ndrop',
        2,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
