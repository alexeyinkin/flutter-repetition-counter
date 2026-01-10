import '../enums/points.dart';
import '../metric_calculators/dx.dart';
import '../metric_calculators/dy.dart';
import '../metric_calculators/metric_calculator.dart';
import '../models/analyzer_message.dart';
import '../models/pose.dart';
import '../models/titled_timed_vector.dart';
import 'analyzer.dart';

/// Calculates metrics from raw body point coordinates.
class MetricsComputer extends Analyzer<Pose, TitledTimedVector> {
  final List<MetricCalculator> metricCalculators;

  MetricsComputer({required this.metricCalculators});

  /// Creates the instance with the default metrics in the application.
  MetricsComputer.lengths() : this(metricCalculators: _lengthMetricCalculators);

  @override
  Future<TitledTimedVector> process(AnalyzerMessage<Pose> message) async {
    return TitledTimedVector(
      [
        for (final calculator in metricCalculators)
          calculator.calculate(
            message.data.landmarks,
            message.data.aspectRatio,
          ),
      ],
      getTitle: (i) => metricCalculators[i].title,
      tick: message.tick,
    );
  }
}

const _lengthMetricCalculators = [
  // Left Arm
  DxCalculator(Points.leftShoulder, Points.leftElbow, title: 'L SHO DX'),
  DyCalculator(Points.leftShoulder, Points.leftElbow, title: 'L SHO DY'),
  DxCalculator(Points.leftElbow, Points.leftWrist, title: 'L FA DX'),
  DyCalculator(Points.leftElbow, Points.leftWrist, title: 'L FA DY'),

  // Right Arm
  DxCalculator(Points.rightShoulder, Points.rightElbow, title: 'R SHO DX'),
  DyCalculator(Points.rightShoulder, Points.rightElbow, title: 'R SHO DY'),
  DxCalculator(Points.rightElbow, Points.rightWrist, title: 'R FA DX'),
  DyCalculator(Points.rightElbow, Points.rightWrist, title: 'R FA DY'),

  // Left Leg
  DxCalculator(Points.leftPelvis, Points.leftKnee, title: 'L HIP DX'),
  DyCalculator(Points.leftPelvis, Points.leftKnee, title: 'L HIP DY'),
  DxCalculator(Points.leftKnee, Points.leftAnkle, title: 'L SHIN DX'),
  DyCalculator(Points.leftKnee, Points.leftAnkle, title: 'L SHIN DY'),

  // Right Leg
  DxCalculator(Points.rightPelvis, Points.rightKnee, title: 'R HIP DX'),
  DyCalculator(Points.rightPelvis, Points.rightKnee, title: 'R HIP DY'),
  DxCalculator(Points.rightKnee, Points.rightAnkle, title: 'R SHIN DX'),
  DyCalculator(Points.rightKnee, Points.rightAnkle, title: 'R SHIN DY'),
];
