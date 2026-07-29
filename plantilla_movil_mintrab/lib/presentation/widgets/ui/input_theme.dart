import 'package:flutter/material.dart';

const _kBorderRadius = BorderRadius.all(Radius.circular(12));

InputDecoration inputDecoration({
  required ColorScheme colors,
  required String label,
  String? hint,
  Widget? prefixIcon,
  Widget? suffixIcon,
}) {
  return InputDecoration(
    labelText: label,
    hintText: hint,
    prefixIcon: prefixIcon,
    suffixIcon: suffixIcon,
    filled: true,
    fillColor: colors.surfaceContainerHighest.withValues(alpha: 0.3),
    enabledBorder: OutlineInputBorder(
      borderRadius: _kBorderRadius,
      borderSide: BorderSide(color: colors.outline.withValues(alpha: 0.5)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: _kBorderRadius,
      borderSide: BorderSide(color: colors.primary, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: _kBorderRadius,
      borderSide: BorderSide(color: colors.error),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: _kBorderRadius,
      borderSide: BorderSide(color: colors.error, width: 2),
    ),
    disabledBorder: OutlineInputBorder(
      borderRadius: _kBorderRadius,
      borderSide: BorderSide(color: colors.outline.withValues(alpha: 0.2)),
    ),
  );
}
