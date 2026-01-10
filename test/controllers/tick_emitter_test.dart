import 'package:fake_async/fake_async.dart';
import 'package:repetition_counter/controllers/tick.dart';
import 'package:repetition_counter/models/analyzer_message.dart';
import 'package:test/test.dart';

void main() {
  group('TickEmitter', () {
    test('start-stop-start', () {
      FakeAsync(initialTime: DateTime(2000)).run((async) {
        final obj = TickEmitter(const Duration(milliseconds: 40));
        final messages = <AnalyzerMessage<void>>[];

        obj.stream.listen(messages.add);

        async.elapse(Duration(seconds: 10));
        obj.start();
        async.elapse(Duration(milliseconds: 80));
        obj.stop();
        async.elapse(Duration(milliseconds: 80));
        obj.start();
        async.elapse(Duration(milliseconds: 80));

        expect(messages.length, 6);

        // start()
        expect(messages[0].tick, 0);
        expect(messages[0].pickedAt, DateTime(2000, 1, 1, 0, 0, 10));
        expect(messages[0].processedAt, messages[0].pickedAt);

        expect(messages[1].tick, 1);
        expect(messages[1].pickedAt, DateTime(2000, 1, 1, 0, 0, 10, 40));
        expect(messages[1].processedAt, messages[1].pickedAt);

        expect(messages[2].tick, 2);
        expect(messages[2].pickedAt, DateTime(2000, 1, 1, 0, 0, 10, 80));
        expect(messages[2].processedAt, messages[2].pickedAt);

        // stop()
        // start()
        expect(messages[3].tick, 3);
        expect(messages[3].pickedAt, DateTime(2000, 1, 1, 0, 0, 10, 160));
        expect(messages[3].processedAt, messages[3].pickedAt);

        expect(messages[4].tick, 4);
        expect(messages[4].pickedAt, DateTime(2000, 1, 1, 0, 0, 10, 200));
        expect(messages[4].processedAt, messages[4].pickedAt);

        expect(messages[5].tick, 5);
        expect(messages[5].pickedAt, DateTime(2000, 1, 1, 0, 0, 10, 240));
        expect(messages[5].processedAt, messages[5].pickedAt);
      });
    });

    test('start twice has no effect', () {
      FakeAsync(initialTime: DateTime(2000)).run((async) {
        final obj = TickEmitter(const Duration(milliseconds: 40));
        final messages = <AnalyzerMessage<void>>[];

        obj.stream.listen(messages.add);

        async.elapse(Duration(seconds: 10));
        obj.start();
        obj.start();
        async.elapse(Duration(milliseconds: 40));

        expect(messages.length, 2);

        expect(messages[0].tick, 0);
        expect(messages[0].pickedAt, DateTime(2000, 1, 1, 0, 0, 10));
        expect(messages[0].processedAt, messages[0].pickedAt);

        expect(messages[1].tick, 1);
        expect(messages[1].pickedAt, DateTime(2000, 1, 1, 0, 0, 10, 40));
        expect(messages[1].processedAt, messages[1].pickedAt);
      });
    });
  });
}
