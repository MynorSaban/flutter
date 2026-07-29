import 'package:flutter/material.dart';
import 'input_theme.dart';

class CustomInputText extends StatelessWidget {
  final TextEditingController value;
  final String label;
  final String? placeholder;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final bool isPassword;
  final TextInputType keyboardType;
  final bool enabled;
  final String? Function(String?)? validator;
  final VoidCallback? onSuffixIconPressed;

  const CustomInputText({
    super.key,
    required this.value,
    required this.label,
    this.placeholder,
    this.prefixIcon,
    this.suffixIcon,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.enabled = true,
    this.validator,
    this.onSuffixIconPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return TextFormField(
      enabled: enabled,
      controller: value,
      obscureText: isPassword,
      keyboardType: keyboardType,
      validator: validator,
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
