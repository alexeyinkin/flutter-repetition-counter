import 'dart:ui';

extension OffsetExtension on Offset {
  Offset timesSize(Size size) => Offset(dx * size.width, dy * size.height);
}
