import 'dart:ui';

extension RectExtension on Rect {
  Rect timesSize(Size size) => Rect.fromLTRB(
    left * size.width,
    top * size.height,
    right * size.width,
    bottom * size.height,
  );
}
