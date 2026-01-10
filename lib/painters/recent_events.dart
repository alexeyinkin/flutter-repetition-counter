import 'dart:ui' as ui;

import 'package:collection/collection.dart';
import 'package:flutter/rendering.dart';

import '../controllers/detectors/abstract.dart';
import '../controllers/event.dart';
import '../controllers/tick.dart';
import '../style.dart';
import '../util/offset.dart';
import '../util/stream.dart';

const _showEventFor = Duration(seconds: 1);
const _introIfIdleFor = Duration(seconds: 5);

/// Paints the splashes of recent events.
class RecentEventsPainter extends CustomPainter {
  final EventAccumulator eventAccumulator;
  final TickEmitter tickEmitter;

  RecentEventsPainter(this.eventAccumulator, {required this.tickEmitter})
    : super(repaint: tickEmitter.stream.listenable);

  @override
  void paint(Canvas canvas, Size size) {
    final painter = EventPainter(canvas: canvas, size: size);
    final dt = _lastTickDateTime;

    if (_shouldPaintIntro()) {
      _paintIntro(canvas, size);
    } else {
      for (final event in eventAccumulator.events) {
        if (dt.difference(event.dateTime) > _showEventFor) {
          break;
        }

        painter.visit(event);
      }
    }
  }

  bool _shouldPaintIntro() {
    final events = eventAccumulator.events;
    if (events.isEmpty) {
      return true;
    }

    final lastRepetition = events.firstWhereOrNull((e) => e is RepetitionEvent);
    if (lastRepetition == null) {
      return true;
    }

    if (_lastTickDateTime.difference(lastRepetition.dateTime) >
        _introIfIdleFor) {
      return true;
    }

    return false;
  }

  DateTime get _lastTickDateTime =>
      tickEmitter.lastMessage?.processedAt ?? DateTime(0);

  void _paintIntro(Canvas canvas, Size size) {
    final pb = ui.ParagraphBuilder(ParagraphStyles.alignCenter);
    pb.pushStyle(TextStyles.intro);
    pb.addText('Do any exercise.\nI will count.');
    final p = pb.build();
    p.layout(const ui.ParagraphConstraints(width: 3000));

    canvas.drawParagraph(
      p,
      Offset(size.width / 2 - p.width / 2, size.height * .6),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class EventPainter extends DetectorEventVisitor<void> {
  final Canvas canvas;
  final Size size;

  const EventPainter({required this.canvas, required this.size});

  @override
  void visitExerciseChangeEvent(ExerciseChangeEvent event) {
    final pb = ui.ParagraphBuilder(ParagraphStyles.alignCenter);
    pb.pushStyle(TextStyles.exerciseChange);
    pb.addText('Exercise Change');
    final p = pb.build();
    p.layout(const ui.ParagraphConstraints(width: 3000));

    canvas.drawParagraph(
      p,
      Offset(size.width / 2 - p.width / 2, size.height * .6),
    );
  }

  @override
  void visitRepetitionEvent(RepetitionEvent event) {
    final pb = ui.ParagraphBuilder(ParagraphStyles.alignCenter);
    pb.pushStyle(TextStyles.repetition);
    pb.addText('${event.number}');
    final p = pb.build();
    p.layout(const ui.ParagraphConstraints(width: 3000));

    final pt = const Offset(.5, .5).timesSize(size);

    canvas.drawParagraph(
      p,
      Offset(pt.dx - p.width / 2, [pt.dy - p.height, .0].max),
    );
  }
}
