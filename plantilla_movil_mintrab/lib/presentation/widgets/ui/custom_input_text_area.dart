import 'package:flutter/material.dart';
import 'input_theme.dart';

class CustomInputTextArea extends StatelessWidget {
  final TextEditingController value;
  final String label;
  final String? placeholder;
  final IconData? prefixIcon;
  final int? maxLength;
  final int minLines;
  final int maxLines;
  final bool enabled;
  final String? Function(String?)? validator;

  const CustomInputTextArea({
    super.key,
    required this.value,
    required this.label,
    this.placeholder,
    this.prefixIcon,
    this.maxLength,
    this.minLines = 3,
    this.maxLines = 5,
    this.enabled = true,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return TextFormField(
      enabled: enabled,
      minLines: minLines,
      maxLines: maxLines,
      maxLength: maxLength,
      controller: value,
      keyboardType: TextInputType.multiline,
      validator: validator,
      style: TextStyle(color: colors.onSurface),
      decoration: inputDecoration(
        colors: colors,
        label: label,
        hint: placeholder,
        prefixIcon:
            prefixIcon != null ? Icon(prefixIcon, color: colors.primary) : null,
      ),
    );
  }
}
