class TitledTimedVector {
  final String Function(int) getTitle;
  final List<double> values;
  final int tick;

  const TitledTimedVector(
    this.values, {
    required this.getTitle,
    required this.tick,
  });

  TitledTimedVector.zero(int length)
    : tick = 0,
      values = List.filled(length, .0, growable: false),
      getTitle = ((i) => '');
}

extension IterableTitledTimedVector on Iterable<TitledTimedVector> {
  List<List<double>> get values => map((v) => v.values).toList(growable: false);
}
