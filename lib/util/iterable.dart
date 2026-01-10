import 'package:collection/collection.dart';

extension IterableDoubleExtension on Iterable<double> {
  Iterable<double> get abs => [for (final el in this) el.abs()];
}

extension ListDobuleExtension on List<double> {
  List<double> plusListInPlace(List<double> other) {
    for (int i = length; --i >= 0;) {
      this[i] += other[i];
    }
    return this;
  }

  List<double> minusList(List<double> other) {
    final result = List<double>.filled(length, .0);

    for (int i = length; --i >= 0;) {
      result[i] = this[i] - other[i];
    }

    return result;
  }

  List<double> divideByInt(int value) {
    return [for (int i = 0; i < length; i++) this[i] / value];
  }

  String dump({required int height, Set<double> guides = const {}}) {
    final chars = List<List<String>>.generate(
      height,
      (i) => List<String>.filled(length, ' '),
    );

    final min = this.min;
    final max = this.max;
    final variance = max - min;

    int valueToBucket(double v) =>
        ((v - min) / variance * (height - .0001)).floor();

    for (int i = length; --i >= 0;) {
      final bucket = valueToBucket(this[i]);
      chars[bucket][i] = '·';
    }

    const dotOverDash = "\u2212\u0307";
    const dotUnderDash = "\u2212\u0323";

    for (final guide in guides) {
      final bucket = valueToBucket(guide);

      for (int i = length; --i >= 0;) {
        final v = this[i];
        final valueBucket = valueToBucket(v);

        if (bucket != valueBucket || v == guide) {
          chars[bucket][i] = '-';
        } else if (v > guide) {
          chars[bucket][i] = dotOverDash;
        } else {
          chars[bucket][i] = dotUnderDash;
        }
      }
    }

    return chars.reversed.map((b) => b.join()).join('\n');
  }
}

extension ListListDoubleExtension on List<List<double>> {
  List<double> get means {
    final result = List<double>.filled(first.length, .0, growable: false);

    for (final row in this) {
      result.plusListInPlace(row);
    }

    return result.divideByInt(length);
  }

  List<List<double>> minusList(List<double> list) {
    final result = <List<double>>[];

    for (final row in this) {
      result.add(row.minusList(list));
    }

    return result;
  }
}

List<double> semigraphicsToList(String chart) {
  final lines = chart.trimRight().split('\n');
  final length = lines.map((l) => l.length).max;

  for (int i = lines.length; --i >= 0;) {
    lines[i] = lines[i].padRight(length);
  }

  final result = List<double>.filled(length, .0);

  for (int i = length; --i >= 0;) {
    for (int j = 0; j < lines.length; j++) {
      if (lines[j][i] == '*') {
        result[i] = (lines.length - j - 1).toDouble();
        break;
      }
    }
  }

  return result;
}
