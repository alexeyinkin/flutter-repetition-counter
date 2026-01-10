import 'dart:typed_data';

class Still {
  final double aspectRatio;
  final Uint8List bytes;

  const Still({required this.aspectRatio, required this.bytes});
}
