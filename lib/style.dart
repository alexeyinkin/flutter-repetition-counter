import 'dart:ui';

class Colors {
  static const chart = Color(0xffffffff);
  static const skeleton = Color(0xffffffff);
}

class Paints {
  static final chartColumn = Paint()
    ..color = Colors.chart
    ..isAntiAlias = true
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1;

  static final chartLine = Paint()
    ..color = Colors.chart
    ..isAntiAlias = true
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2;

  static final skeleton = Paint()
    ..color = Colors.skeleton
    ..isAntiAlias = true
    ..style = PaintingStyle.fill
    ..strokeWidth = 5;
}

class ParagraphStyles {
  static final alignLeft = ParagraphStyle(
    textAlign: TextAlign.left,
  );

  static final alignRight = ParagraphStyle(
    textAlign: TextAlign.right,
  );
}

class TextStyles {
  static final chartTitle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Colors.chart,
  );

  static final chartLabel = TextStyle(
    fontSize: 10,
    color: Colors.chart,
  );
}
