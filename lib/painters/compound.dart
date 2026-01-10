import 'package:flutter/rendering.dart';

/// Makes all nested [painters] paint.
class CompoundPainter extends CustomPainter {
  List<CustomPainter> painters = [];

  CompoundPainter({required super.repaint});

  @override
  void paint(Canvas canvas, Size size) {
    for (final painter in painters) {
      painter.paint(canvas, size);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
