import 'package:flutter/material.dart';

class CustomInputText extends StatelessWidget {
  final TextEditingController value;
  final String label;
  final String? hintText;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final bool isPassword;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final VoidCallback? onSuffixIconPressed;

  const CustomInputText({
    super.key,
    required this.value,
    required this.label,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.onSuffixIconPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return TextFormField(
      controller: value,
      obscureText: isPassword,
      keyboardType: keyboardType,
      validator: validator,
      // Estilo del texto que escribe el usuario
      style: TextStyle(color: colors.onSurface),
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        // Icono al inicio del input
        prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: colors.primary) : null,
        // Icono al final (útil para mostrar/ocultar contraseñas)
        suffixIcon: suffixIcon != null 
            ? IconButton(
                icon: Icon(suffixIcon, color: colors.primary),
                onPressed: onSuffixIconPressed,
              )
            : null,
        
        // Diseños de los bordes basados en tu tema
        filled: true,
        fillColor: colors.surfaceContainerHighest.withValues(alpha: 0.3),
      
      
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.error),
        ),
      ),
    );
  }
}
