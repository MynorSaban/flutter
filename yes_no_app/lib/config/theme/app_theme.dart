import 'package:flutter/material.dart';

const Color _customColor = Color(0XFF5C1104);

const List<Color> _colorList = [
  _customColor,
  Colors.blue,
  Colors.green,
  Colors.yellow,
  Colors.pink,
  Colors.deepPurple,
];

class AppTheme {
  final int selectedColorIndex;

  AppTheme({this.selectedColorIndex = 0})
    : assert(
        selectedColorIndex >= 0 && selectedColorIndex < _colorList.length,
        'selectedColorIndex must be between 0 and ${_colorList.length - 1}',
      );

  ThemeData theme() {
    return ThemeData(
      useMaterial3: true,
      colorSchemeSeed: _colorList[selectedColorIndex],
    );
  }
}
