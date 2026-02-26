import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

const _borderWidth = 5.0;

const _color = Color(0xffa0a0a0);
const _selectedColor = Colors.white;
const _fillColor = Color(0x80ffffff);

final _fontSizesFromWidth = {150.0: 24.0, 100.0: 18.0, .0: 15.0};

final _fontSizesFromHeight = {80.0: 24.0, 60.0: 18.0, .0: 15.0};

final _iconSizes = {150.0: 150.0, 100.0: 100.0, .0: 60.0};

class MyToggleButtons extends StatelessWidget {
  final List<Widget> children;
  final List<bool> isSelected;
  final void Function(int index) onPressed;

  const MyToggleButtons({
    required this.children,
    required this.isSelected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxInnerWidth =
            (constraints.maxWidth - (children.length + 1) * _borderWidth) /
            children.length;
        final maxInnerHeight = constraints.maxHeight - _borderWidth * 2;

        final fontSizeFromWidth = _fontSizesFromWidth.entries
            .firstWhere((e) => e.key < maxInnerWidth)
            .value;
        final fontSizeFromHeight = _fontSizesFromHeight.entries
            .firstWhere((e) => e.key < maxInnerHeight)
            .value;
        final fontSize = min(fontSizeFromWidth, fontSizeFromHeight);

        final minInnerSize = min(maxInnerWidth, maxInnerHeight);
        final iconSize = _iconSizes.entries
            .firstWhere((e) => e.key < minInnerSize)
            .value;

        return ToggleButtons(
          color: _color,
          selectedColor: _selectedColor,
          constraints: BoxConstraints.expand(width: maxInnerWidth),
          borderWidth: _borderWidth,
          borderRadius: const BorderRadius.all(Radius.circular(16)),
          borderColor: _color,
          selectedBorderColor: _selectedColor,
          fillColor: _fillColor,
          isSelected: isSelected,
          onPressed: onPressed,
          textStyle: TextStyle(
            fontSize: fontSize,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
          children: children
              .mapIndexed(
                (i, w) => IconTheme(
                  data: IconThemeData(
                    size: iconSize,
                    color: isSelected[i] ? _selectedColor : _color,
                  ),
                  child: w,
                ),
              )
              .toList(growable: false),
        );
      },
    );
  }
}
