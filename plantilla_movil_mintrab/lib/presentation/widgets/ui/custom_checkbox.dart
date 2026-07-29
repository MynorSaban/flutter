import 'package:flutter/material.dart';

class CustomCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?> onChanged;
  final String label;
  final bool enabled;

  const CustomCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    required this.label,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return CheckboxListTile(
      value: value,
      onChanged: enabled ? onChanged : null,
      title: Text(
        label,
        style: TextStyle(
          color: enabled
              ? colors.onSurface
              : colors.onSurface.withValues(alpha: 0.4),
        ),
      ),
      activeColor: colors.primary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      contentPadding: EdgeInsets.zero,
      controlAffinity: ListTileControlAffinity.leading,
    );
  }
}
