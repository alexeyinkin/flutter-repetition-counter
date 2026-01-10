import '../models/analyzer_message.dart';

abstract class MessageEmitter<Output> {
  Stream<AnalyzerMessage<Output>> get stream;

  AnalyzerMessage<Output>? get lastMessage;
}
