import 'package:flutter/material.dart';

class RadioOption<T> {
  final T value;
  final String label;

  const RadioOption({required this.value, required this.label});
}

class CustomRadioGroup<T> extends StatelessWidget {
  final List<RadioOption<T>> options;
  final T? groupValue;
  final ValueChanged<T?> onChanged;
  final String? label;
  final bool enabled;

  const CustomRadioGroup({
    super.key,
    required this.options,
    required this.groupValue,
    required this.onChanged,
    this.label,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return IgnorePointer(
      ignoring: !enabled,
      child: Opacity(
        opacity: enabled ? 1.0 : 0.4,
        child: RadioGroup<T>(
          groupValue: groupValue,
          onChanged: onChanged,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (label != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4, left: 4),
                  child: Text(
                    label!,
                    style: TextStyle(
                      fontSize: 14,
                      color: colors.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              ...options.map(
                (option) => RadioListTile<T>(
                  value: option.value,
                  title: Text(
                    option.label,
                    style: TextStyle(color: colors.onSurface),
                  ),
                  activeColor: colors.primary,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
