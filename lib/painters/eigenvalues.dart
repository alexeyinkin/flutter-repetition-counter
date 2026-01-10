import 'package:collection/collection.dart';
import 'package:flutter/rendering.dart';

import '../controllers/pca.dart';
import '../style.dart';
import '../util/rect.dart';

const _columnRelativeWidth = .8;

/// Paints the column chart of eigenvalues.
class EigenvaluesPainter extends CustomPainter {
  final PrincipalComponentAnalyzer pca;
  final Rect normalizedRect;

  EigenvaluesPainter(this.pca, {required this.normalizedRect});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = normalizedRect.timesSize(size);
    canvas.drawRect(rect, Paints.chartLine);

    final e = pca.singularValues
        .map((v) => v * v)
        .toList(growable: false);
    final sum = e.sum;

    if (sum == 0) {
      return;
    }

    final step = rect.width / e.length;
    final columnWidth = step * _columnRelativeWidth;

    for (int i = e.length; --i >= 0;) {
      final ratio = e[i] / sum;
      final height = ratio * rect.height;
      final left = rect.left + step * i + (1 - _columnRelativeWidth) / 2;

      canvas.drawRect(
        Rect.fromLTWH(left, rect.bottom - height, columnWidth, height),
        Paints.chartFill,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
