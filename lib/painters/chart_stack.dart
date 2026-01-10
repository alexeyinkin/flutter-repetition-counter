import 'package:collection/collection.dart';
import 'package:flutter/rendering.dart';

import '../controllers/message_emitter.dart';
import '../models/titled_timed_matrix.dart';
import '../util/iterable.dart';
import '../util/rect.dart';
import '../util/stream.dart';
import 'chart.dart';

class ChartStackPainter extends CustomPainter {
  final MessageEmitter<TitledTimedMatrix> titledMatrixEmitter;
  final Rect normalizedRect;

  ChartStackPainter(this.titledMatrixEmitter, {required this.normalizedRect})
    : super(repaint: titledMatrixEmitter.stream.listenable);

  @override
  void paint(Canvas canvas, Size size) {
    final message = titledMatrixEmitter.lastMessage;

    if (message == null) {
      return;
    }

    final rect = normalizedRect.timesSize(size);

    final chartCount = message.data.rows.first.values.length;
    final h = rect.height / chartCount;

    // TODO: Cache?
    final maxAbs = message.data.rows.map((list) => list.values.abs.max).abs.max;

    for (int i = chartCount; --i >= 0;) {
      final painter = ChartPainter(
        message.data.getColumn(i),
        maxAbs: maxAbs,
        overlays: const [],
        rect: Rect.fromLTWH(rect.left, rect.top + i * h, rect.width, h),
        seriesType: .line,
        showWindowLabels: false,
        title: message.data.getTitle(i),
        xScaleMode: .dataPoints,
        yRangeMode: .negativeMaxToMax,
      );
      painter.paint(canvas, size);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
