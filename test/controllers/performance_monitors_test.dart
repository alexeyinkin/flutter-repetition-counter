import 'package:repetition_counter/controllers/performance_monitor.dart';
import 'package:repetition_counter/controllers/performance_monitors.dart';
import 'package:test/test.dart';

void main() {
  group('PerformanceMonitors', () {
    test('length', () {
      final obj = PerformanceMonitors();

      expect(obj.length, 0);

      obj.add(PerformanceMonitor(length: 3, title: ''));

      expect(obj.length, 1);
    });

    test('monitors', () {
      final obj = PerformanceMonitors();
      final m1 = PerformanceMonitor(length: 3, title: 'a');
      final m2 = PerformanceMonitor(length: 3, title: 'b');
      obj.add(m1);
      obj.add(m2);

      expect(obj.monitors[0].title, 'a');
      expect(obj.monitors[1].title, 'b');
    });

    test('throws if monitors of different lengths', () {
      final obj = PerformanceMonitors();

      obj.add(PerformanceMonitor(length: 3, title: ''));
      obj.add(PerformanceMonitor(length: 3, title: ''));

      expect(() => obj.add(PerformanceMonitor(length: 4, title: '')), throwsArgumentError);
    });
  });
}
