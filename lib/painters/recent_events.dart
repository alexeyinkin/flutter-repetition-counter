import 'dart:ui' as ui;

import 'package:collection/collection.dart';
import 'package:flutter/rendering.dart';

import '../controllers/detectors/abstract.dart';
import '../controllers/event.dart';
import '../controllers/tick.dart';
import '../style.dart';
import '../util/offset.dart';
import '../util/stream.dart';

/// How long to show an event for.
const _duration = 25;

/// Paints the splashes of recent events.
class RecentEventsPainter extends CustomPainter {
  final EventAccumulator eventAccumulator;
  final TickEmitter tickEmitter;

  RecentEventsPainter(this.eventAccumulator, {required this.tickEmitter})
    : super(repaint: tickEmitter.stream.listenable);

  @override
  void paint(Canvas canvas, Size size) {
    final painter = EventPainter(canvas: canvas, size: size);
    final tick = tickEmitter.lastMessage?.tick ?? 0;

    for (final event in eventAccumulator.events) {
      if (tick - event.tick > _duration) {
        break;
      }

      painter.visit(event);
    }
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
