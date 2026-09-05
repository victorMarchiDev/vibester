import 'package:flutter/material.dart';
import 'package:mobile/theme/app_motion.dart';
import 'package:mobile/theme/theme_extensions.dart';

/// Selo de identidade em Geist Pixel, para elementos de destaque pontuais
/// (ex. evento em destaque). Não usar para texto longo, formulários ou
/// navegação — ver `AppTypography.pixelBadge`.
///
/// Entra com scale + overshoot + snap (seção 29 do briefing de motion 2.0),
/// não simplesmente aparece.
class PixelBadge extends StatelessWidget {
  final String label;

  const PixelBadge({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: context.adaptiveMotion(AppMotion.ui),
      curve: AppMotion.emphasis,
      builder: (context, scale, child) =>
          Transform.scale(scale: scale, child: child),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: context.colors.ambar,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label.toUpperCase(),
          style: context.typography.pixelBadge.copyWith(color: Colors.white),
        ),
      ),
    );
  }
}
