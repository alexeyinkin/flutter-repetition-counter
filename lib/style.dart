import 'dart:ui';

class Colors {
  static const chart = Color(0xffffffff);
  static const exerciseChange = Color(0xffffa0a0);
  static const repetition = Color(0xffa0a0ff);
  static const skeleton = Color(0xffffffff);
  static const textBorder = Color(0xffffffff);
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

  static final alignCenter = ParagraphStyle(
    textAlign: TextAlign.center,
  );

  static final alignRight = ParagraphStyle(
    textAlign: TextAlign.right,
  );
}

class TextStyles {
  static final exerciseChange = TextStyle(
    fontSize: 96,
    fontWeight: FontWeight.bold,
    shadows: [
      Shadow(color: Colors.textBorder, blurRadius: 15),
      Shadow(color: Colors.textBorder, blurRadius: 15),
      Shadow(color: Colors.textBorder, blurRadius: 15),
    ],
    color: Colors.exerciseChange,
  );

  static final repetition = TextStyle(
    fontSize: 192,
    fontWeight: FontWeight.bold,
    shadows: [
      Shadow(color: Colors.textBorder, blurRadius: 30),
      Shadow(color: Colors.textBorder, blurRadius: 30),
      Shadow(color: Colors.textBorder, blurRadius: 30),
    ],
    color: Colors.repetition,
  );

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
