import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'input_theme.dart';

class CustomInputNumber extends StatelessWidget {
  final TextEditingController value;
  final String label;
  final String? placeholder;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final bool enabled;
  final int? maxLength;
  final String? Function(String?)? validator;
  final VoidCallback? onSuffixIconPressed;

  const CustomInputNumber({
    super.key,
    required this.value,
    required this.label,
    this.placeholder,
    this.prefixIcon,
    this.suffixIcon,
    this.enabled = true,
    this.validator,
    this.onSuffixIconPressed,
    this.maxLength
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return TextFormField(
      enabled: enabled,
      controller: value,
      keyboardType: TextInputType.number, // teclado numérico
      inputFormatters: [FilteringTextInputFormatter.digitsOnly,],
      validator: validator,
      maxLength: maxLength,
      style: TextStyle(color: colors.onSurface),
      decoration: inputDecoration(
        colors: colors,
        label: label,
        hint: placeholder,
        prefixIcon:
            prefixIcon != null ? Icon(prefixIcon, color: colors.primary) : null,
        suffixIcon: suffixIcon != null
            ? IconButton(
                icon: Icon(suffixIcon, color: colors.primary),
                onPressed: onSuffixIconPressed,
              )
            : null,
            
      ),
    );
  }
}
