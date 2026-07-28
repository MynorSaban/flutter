import 'package:flutter/material.dart';

class HeaderComponent extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subTitle;
  final double? shade;

  const HeaderComponent({
    super.key,
    required this.title,
    this.shade,
    this.subTitle,
  });

  @override
  Size get preferredSize => Size.fromHeight(subTitle != null ? 60.0 : kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final currentColor = Theme.of(context).colorScheme;
    final effectiveBackgroundColor = currentColor.primary;

    return AppBar(
      backgroundColor: effectiveBackgroundColor,
      foregroundColor: currentColor.onPrimary,
      scrolledUnderElevation: 0, // Evita variaciones de color al hacer scroll
      title: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start, // Alinea los textos a la izquierda
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: subTitle != null ? 20 : 24, // Se achica la letra si viene el subtitulo
              fontWeight: FontWeight.bold,
              color: currentColor.onPrimary,
              letterSpacing: 1,
            ),
          ),
          if (subTitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subTitle!,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500, // Un poco más delgado que el título para jerarquía visual
                color: currentColor.onPrimary.withValues(alpha: 0.85),
                letterSpacing: 1,
              ),
            ),
          ],
        ],
      ),
      elevation: shade,
    );
  }
}
