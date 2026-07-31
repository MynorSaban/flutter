import 'package:flutter/material.dart';

enum AlertType { info, success, warning, danger }

abstract final class CustomAlertDialog {
  static Future<bool?> show({
    required BuildContext context,
    required String title,
    String? message,
    AlertType type = AlertType.info,
    String confirmLabel = 'Aceptar',
    String? cancelLabel,
  }) {
    final colors = Theme.of(context).colorScheme;
    final (icon, iconColor) = switch (type) {
      AlertType.info => (Icons.shape_line_rounded, colors.primary),
      AlertType.success => (Icons.check_circle_outline_rounded, Colors.green),
      AlertType.warning => (Icons.warning_amber_rounded, Colors.orange),
      AlertType.danger => (Icons.error_outline_rounded, colors.error),
    };

    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        insetPadding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 24.0),
        icon: Icon(icon, size: 100, color: iconColor),
        title: Text(title, textAlign: TextAlign.center),
        content: SizedBox(width: 350, child: Text(message??'', textAlign: TextAlign.justify)),
        actionsAlignment: MainAxisAlignment.center,


        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          Row(  
            children: [
              if (cancelLabel != null)
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(ctx).pop(false),
                    child: Text(cancelLabel),
                  ),
                ),
                SizedBox(width: 5),
              Expanded(
                child: FilledButton(
                  onPressed: () => Navigator.of(ctx).pop(true),
                  style: FilledButton.styleFrom(backgroundColor: iconColor),
                  child: Text(confirmLabel),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
