import 'titled_timed_vector.dart';

/// Stores time series. 1st dimension is a sample, 2nd dimension is a series.
class TitledTimedMatrix {
  final String Function(int) getTitle;
  final List<TitledTimedVector> rows;

  const TitledTimedMatrix(this.rows, {required this.getTitle});

  List<(int, double)> getColumn(int index) {
    return rows
        .map((list) => (list.tick, list.values[index]))
        .toList(growable: false);
  }
}
