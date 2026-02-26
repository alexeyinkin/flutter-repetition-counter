import 'dart:typed_data';

sealed class Still {
  final double aspectRatio;
  final int needsClockwiseQuarterTurns;
  final bool needsHorizontalFlipping;

  const Still({
    required this.aspectRatio,
    required this.needsClockwiseQuarterTurns,
    required this.needsHorizontalFlipping,
  });
}

class EncodedStill extends Still {
  final Uint8List bytes;

  const EncodedStill({
    required super.aspectRatio,
    required super.needsClockwiseQuarterTurns,
    required super.needsHorizontalFlipping,
    required this.bytes,
  });
}

class PlanesStill extends Still {
  final List<Uint8List> planes;
  final int width;
  final int height;

  const PlanesStill({
    required super.aspectRatio,
    required super.needsClockwiseQuarterTurns,
    required super.needsHorizontalFlipping,
    required this.planes,
    required this.width,
    required this.height,
  });
}
