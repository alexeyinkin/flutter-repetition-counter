import 'package:fake_async/fake_async.dart';
import 'package:repetition_counter/controllers/analyzer.dart';
import 'package:repetition_counter/controllers/tick.dart';
import 'package:repetition_counter/models/analyzer_message.dart';
import 'package:test/test.dart';

class FooAnalyzer extends Analyzer {
  @override
  Future<int> process(AnalyzerMessage<dynamic> message) async {
    await Future.delayed(Duration(milliseconds: message.tick * 15));
    return 1;
  }
}

void main() {
  group('AsyncAnalyzer', () {
    test('', () {
      FakeAsync(initialTime: DateTime(2000)).run((async) {
        final r = <AnalyzerMessage>[];
        final obj = FooAnalyzer();
        final te = TickEmitter(const Duration(milliseconds: 40));
        te.stream.listen(obj.sink.add);
        obj.stream.listen(r.add);

        te.start();
        async.elapse(te.step * 15);

        expect(r.length, 8);

        // 0: Emitted at 0
        expect(r[0].tick, 0);
        expect(r[0].pickedAt, DateTime(2000));
        expect(r[0].processedAt, DateTime(2000));
        expect(r[0].data, 1);

        // 1: Emitted at 40
        expect(r[1].tick, 1);
        expect(r[1].pickedAt, DateTime(2000, 1, 1, 0, 0, 0, 40));
        expect(r[1].processedAt, DateTime(2000, 1, 1, 0, 0, 0, 55));

        // 2: Emitted at 80
        expect(r[2].tick, 2);
        expect(r[2].pickedAt, DateTime(2000, 1, 1, 0, 0, 0, 80));
        expect(r[2].processedAt, DateTime(2000, 1, 1, 0, 0, 0, 110));

        // 3: Emitted at 120
        expect(r[3].tick, 3);
        expect(r[3].pickedAt, DateTime(2000, 1, 1, 0, 0, 0, 120));
        expect(r[3].processedAt, DateTime(2000, 1, 1, 0, 0, 0, 165));

        // 4: Emitted at 160
        expect(r[4].tick, 4);
        expect(r[4].pickedAt, DateTime(2000, 1, 1, 0, 0, 0, 165));
        expect(r[4].processedAt, DateTime(2000, 1, 1, 0, 0, 0, 225));

        // 5: Emitted at 200
        expect(r[5].tick, 5);
        expect(r[5].pickedAt, DateTime(2000, 1, 1, 0, 0, 0, 225));
        expect(r[5].processedAt, DateTime(2000, 1, 1, 0, 0, 0, 300));

        // 6: Emitted at 240 -> Dropped

        // 7: Emitted at 280
        expect(r[6].tick, 7);
        expect(r[6].pickedAt, DateTime(2000, 1, 1, 0, 0, 0, 300));
        expect(r[6].processedAt, DateTime(2000, 1, 1, 0, 0, 0, 405));

        // 8: Emitted at 320 -> Dropped
        // 9: Emitted at 360 -> Dropped

        // 10: Emitted at 400
        expect(r[7].tick, 10);
        expect(r[7].pickedAt, DateTime(2000, 1, 1, 0, 0, 0, 405));
        expect(r[7].processedAt, DateTime(2000, 1, 1, 0, 0, 0, 555));
      });
    });
  });
}
