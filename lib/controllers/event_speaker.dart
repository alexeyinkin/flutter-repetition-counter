import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/analyzer_message.dart';
import 'detectors/abstract.dart';

const _maxTicksAgo = 7; // TODO: Use time
const _isMuteKey = 'mute';

/// Plays a sound when an event is detected.
class EventSpeaker extends DetectorEventVisitor<void> with ChangeNotifier {
  final SharedPreferencesWithCache _pref;

  StreamSink<AnalyzerMessage> get tickSink => _tickStreamController.sink;
  final _tickStreamController = StreamController<AnalyzerMessage>();

  StreamSink<DetectorEvent> get eventSink => _eventStreamController.sink;
  final _eventStreamController = StreamController<DetectorEvent>();

  final tts = FlutterTts();

  int _lastTick = 0;
  bool _isMute;

  EventSpeaker(this._pref) : _isMute = _pref.getBool(_isMuteKey) ?? false {
    unawaited(_init());
    _tickStreamController.stream.listen((m) => _lastTick = m.tick);
    _eventStreamController.stream.listen(_onEvent);
  }

  Future<void> _init() async {
    if (!kIsWeb) {
      if (Platform.isIOS) {
        await tts.setIosAudioCategory(
          IosTextToSpeechAudioCategory.ambient,
          [
            IosTextToSpeechAudioCategoryOptions.allowBluetooth,
            IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
            IosTextToSpeechAudioCategoryOptions.mixWithOthers,
          ],
          IosTextToSpeechAudioMode.voicePrompt,
        );
      }
    }
  }

  void _onEvent(DetectorEvent event) {
    if (_lastTick - event.tick > _maxTicksAgo) {
      return;
    }

    visit(event);
  }

  bool get isMute => _isMute;

  set isMute(bool newValue) {
    if (newValue == _isMute) {
      return;
    }

    unawaited(_pref.setBool(_isMuteKey, newValue));
    _isMute = newValue;
    notifyListeners();
  }

  @override
  void visitExerciseChangeEvent(ExerciseChangeEvent event) {}

  @override
  Future<void> visitRepetitionEvent(RepetitionEvent event) async {
    if (_isMute) {
      return;
    }

    await tts.stop();
    await tts.speak('${event.number}');
  }
}
