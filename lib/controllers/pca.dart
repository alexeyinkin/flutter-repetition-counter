import 'package:repetition_counter/models/analyzer_message.dart';
import 'package:scidart/numdart.dart';

import '../models/titled_timed_matrix.dart';
import '../models/titled_timed_vector.dart';
import '../util/iterable.dart';
import 'analyzer.dart';

String _getTitle(int i) => 'PC ${i + 1}';

class PrincipalComponentAnalyzer
    extends Analyzer<TitledTimedMatrix, TitledTimedMatrix> {
  /// How many last data points from the input to analyze.
  final int analyzeDataPoints;

  /// How many dimensions to keep.
  final int dimensions;

  /// For which dimensions to lock the sign.
  final Set<int> stabilizeSigns;

  /// The last result of Singular Value Decomposition.
  SVD? _svd;

  int? _sampleLength;

  /// Which dimensions were flipped from what SVD returned to lock the signs.
  Set<int> _flippedDimensions = <int>{};

  PrincipalComponentAnalyzer({
    required this.analyzeDataPoints,
    required this.dimensions,
    required this.stabilizeSigns,
  });

  @override
  Future<TitledTimedMatrix?> process(
    AnalyzerMessage<TitledTimedMatrix> message,
  ) async {
    final analyzeList = message.data.rows.sublist(0, analyzeDataPoints).values;
    final means = analyzeList.means;

    final analyzeM = Array2d(
      analyzeList.minusList(means).map(Array.new).toList(growable: false),
    );
    _sampleLength = analyzeM.column;
    final svd = SVD(analyzeM);

    final (v, flipped) = _fixVSigns(svd.V());
    final vReduced = _firstColumns(v);
    final fullList = message.data.rows.values;

    final fullM = Array2d(
      fullList.minusList(means).map(Array.new).toList(growable: false),
    );
    final fullMReduced = matrixDot(fullM, vReduced);

    // Store for the next step.
    _svd = svd;
    _flippedDimensions = flipped;

    return TitledTimedMatrix([
      for (int i = 0; i < fullMReduced.length; i++)
        TitledTimedVector(
          fullMReduced[i],
          getTitle: _getTitle,
          tick: message.data.rows[i].tick,
        ),
    ], getTitle: _getTitle);
  }

  /// The first iterative version of [process] used in the tutorial.
  Future<TitledTimedMatrix?> _process_first(
    AnalyzerMessage<TitledTimedMatrix> message,
  ) async {
    // Convert our data to the scidart format.
    final m = Array2d(
      message.data.rows.values.map(Array.new).toList(growable: false),
    );
    final svd = SVD(m);

    final result = matrixDot(m, svd.V());

    return TitledTimedMatrix([
      for (int i = 0; i < result.length; i++)
        TitledTimedVector(
          result[i],
          getTitle: _getTitle,
          tick: message.data.rows[i].tick,
        ),
    ], getTitle: _getTitle);
  }

  /// The second iterative version of [process] used in the tutorial.
  Future<TitledTimedMatrix?> _process_dimensions(
    AnalyzerMessage<TitledTimedMatrix> message,
  ) async {
    // Convert our data to the scidart format.
    final m = Array2d(
      message.data.rows.values.map(Array.new).toList(growable: false),
    );
    final svd = SVD(m);

    final result = matrixDot(m, _firstColumns(svd.V()));

    return TitledTimedMatrix([
      for (int i = 0; i < result.length; i++)
        TitledTimedVector(
          result[i],
          getTitle: _getTitle,
          tick: message.data.rows[i].tick,
        ),
    ], getTitle: _getTitle);
  }

  /// The third iterative version of [process] used in the tutorial.
  Future<TitledTimedMatrix?> _process_center(
    AnalyzerMessage<TitledTimedMatrix> message,
  ) async {
    final rowValues = message.data.rows.values;
    final means = rowValues.means;

    final m = Array2d(
      rowValues.minusList(means).map(Array.new).toList(growable: false),
    );
    final svd = SVD(m);

    final result = matrixDot(m, _firstColumns(svd.V()));

    return TitledTimedMatrix([
      for (int i = 0; i < result.length; i++)
        TitledTimedVector(
          result[i],
          getTitle: _getTitle,
          tick: message.data.rows[i].tick,
        ),
    ], getTitle: _getTitle);
  }

  /// The fourth iterative version of [process] used in the tutorial.
  Future<TitledTimedMatrix?> _process_flip(
    AnalyzerMessage<TitledTimedMatrix> message,
  ) async {
    final rowValues = message.data.rows.values;
    final means = rowValues.means;

    final m = Array2d(
      rowValues.minusList(means).map(Array.new).toList(growable: false),
    );
    final svd = SVD(m);

    final (v, flipped) = _fixVSigns(svd.V());
    final vReduced = _firstColumns(v);
    final result = matrixDot(m, _firstColumns(vReduced));

    // Store for the next step.
    _svd = svd;
    _flippedDimensions = flipped;

    return TitledTimedMatrix([
      for (int i = 0; i < result.length; i++)
        TitledTimedVector(
          result[i],
          getTitle: _getTitle,
          tick: message.data.rows[i].tick,
        ),
    ], getTitle: _getTitle);
  }

  Array2d _firstColumns(Array2d v) {
    return v.subArray2d(0, v.row - 1, 0, dimensions - 1);
  }

  /// Fixes signs in [v] to keep the result consistent with the last tick.
  ///
  /// Returns the fixed [v] and the flipped dimensions.
  (Array2d, Set<int>) _fixVSigns(Array2d v) {
    v = Array2d.fromArray(v);
    if (_svd == null) {
      return (v, {});
    }

    final lastV = _svd!.V();
    final flipped = <int>{};

    for (final column in stabilizeSigns) {
      double dot = .0;

      for (int i = lastV.row; --i >= 0;) {
        dot += lastV[i][column] * v[i][column];
      }

      // Flip in two cases:
      // 1. Dot product is negative AND the dimension was not flipped last time.
      // 2. Dot product is positive AND the dimension was flipped last time.
      if (dot < 0 != _flippedDimensions.contains(column)) {
        flipped.add(column);
        for (int i = lastV.row; --i >= 0;) {
          v[i][column] = -v[i][column];
        }
      }
    }

    return (v, flipped);
  }

  // Bug in scidart, number of values == number of rows instead of columns.
  List<double> get singularValues =>
      _svd?.singularValues().sublist(0, _sampleLength ?? dimensions) ??
      List<double>.filled(dimensions, .0);
}
