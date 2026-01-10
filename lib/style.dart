import 'dart:ui';

class Colors {
  static const skeleton = Color(0xffffffff);
}

class Paints {
  static final skeleton = Paint()
    ..color = Colors.skeleton
    ..isAntiAlias = true
    ..style = PaintingStyle.fill
    ..strokeWidth = 5;
}
