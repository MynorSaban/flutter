import 'package:flutter/material.dart';

class Button extends StatelessWidget {
  final IconData? icon;
  final String? label;
  final VoidCallback? onPressed;
  final double? shade;
  const Button({super.key, this.icon, this.label, this.onPressed, this.shade});

  @override
  Widget build(BuildContext context) {
     return FloatingActionButton(
      enableFeedback: true,
      elevation: shade,      
      shape: const StadiumBorder(),
      onPressed: onPressed,
      tooltip: label,
      child: Icon(icon),
    );
  } 
}
