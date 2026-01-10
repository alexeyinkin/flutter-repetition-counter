import '../models/analyzer_message.dart';
import '../models/titled_timed_matrix.dart';
import '../models/titled_timed_vector.dart';
import '../util/circular_buffer.dart';
import 'analyzer.dart';

class TimeSeriesAccumulator
    extends Analyzer<TitledTimedVector, TitledTimedMatrix> {
  final int length;
  final int vectorLength;
  final CircularBuffer<TitledTimedVector> _buffer;

  TimeSeriesAccumulator({required this.length, required this.vectorLength})
    : _buffer = CircularBuffer(
        List.filled(length, TitledTimedVector.zero(vectorLength)),
      );

  @override
  Future<TitledTimedMatrix> process(
    AnalyzerMessage<TitledTimedVector> message,
  ) async {
    _buffer.add(message.data);
    return TitledTimedMatrix(
      _buffer.shallowCopyList(),
      getTitle: message.data.getTitle,
    );
  }
}
