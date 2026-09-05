import 'package:flutter/material.dart';

/// Tokens de tipografia do Vibester, usando Geist Sans como fonte principal
/// (aplicada globalmente via `ThemeData.fontFamily` em [AppTheme]) e Geist
/// Pixel como fonte de destaque, usada com extrema moderação (ver
/// [pixelBadge]).
///
/// Ao contrário de `AppColors`, esta classe NÃO é um `ThemeExtension`:
/// tamanho/peso/tracking não variam entre tema claro/escuro no Vibester —
/// só a cor do texto varia, e isso já é resolvido separadamente via
/// `context.colors.*`. Um `lerp` aqui seria ritual sem propósito real, então
/// optamos por uma instância `const` única, acessada via `context.typography`
/// (`theme_extensions.dart`).
class AppTypography {
  const AppTypography({
    required this.displayLarge,
    required this.displayMedium,
    required this.headlineLarge,
    required this.headlineMedium,
    required this.headlineSmall,
    required this.titleLarge,
    required this.titleMedium,
    required this.titleSmall,
    required this.bodyLarge,
    required this.bodyMedium,
    required this.bodySmall,
    required this.labelLarge,
    required this.labelMedium,
    required this.labelSmall,
    required this.pixelBadge,
  });

  /// Título de evento em destaque (ex. topo de `event_detail_screen`).
  final TextStyle displayLarge;

  /// Header de seção grande (ex. "Populares Agora").
  final TextStyle displayMedium;

  /// Título das telas de onboarding.
  final TextStyle headlineLarge;

  /// Título de evento em card (`event_card`, `featured_events`).
  final TextStyle headlineMedium;

  /// Nome de estabelecimento em card.
  final TextStyle headlineSmall;

  /// Subtítulo forte / header de bloco.
  final TextStyle titleLarge;

  /// Label de botão, artistas do evento, CTA de card.
  final TextStyle titleMedium;

  /// Label bold pequeno ("Movimento", tabs).
  final TextStyle titleSmall;

  /// Corpo principal / descrição.
  final TextStyle bodyLarge;

  /// Corpo secundário (ex. texto explicativo de onboarding).
  final TextStyle bodyMedium;

  /// Caption.
  final TextStyle bodySmall;

  /// Label de botão pequeno / tab.
  final TextStyle labelLarge;

  /// Chip / badge legível.
  final TextStyle labelMedium;

  /// Selo mínimo (ex. `category_indicator`).
  final TextStyle labelSmall;

  /// Geist Pixel — uso raro e estratégico (badges de identidade/destaque).
  /// Nunca usar em texto longo, formulários, navegação ou corpo de texto.
  final TextStyle pixelBadge;

  static const AppTypography instance = AppTypography(
    displayLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.5,
      height: 1.1,
    ),
    displayMedium: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.3,
      height: 1.15,
    ),
    headlineLarge: TextStyle(
      fontSize: 26,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.4,
      height: 1.15,
    ),
    headlineMedium: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w700,
      letterSpacing: 0,
      height: 1.2,
    ),
    headlineSmall: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
      height: 1.25,
    ),
    titleLarge: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
      height: 1.3,
    ),
    titleMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
      height: 1.3,
    ),
    titleSmall: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
      height: 1.3,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      height: 1.4,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      height: 1.5,
    ),
    bodySmall: TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      height: 1.4,
    ),
    labelLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
      height: 1.2,
    ),
    labelMedium: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.2,
      height: 1.2,
    ),
    labelSmall: TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.3,
      height: 1.1,
    ),
    pixelBadge: TextStyle(
      fontFamily: 'GeistPixel',
      fontSize: 11,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.5,
      height: 1.0,
    ),
  );
}
