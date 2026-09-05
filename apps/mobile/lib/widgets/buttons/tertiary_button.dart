import 'package:flutter/material.dart';
import 'package:mobile/theme/app_motion.dart';
import 'package:mobile/theme/theme_extensions.dart';
import 'package:mobile/widgets/motion/vibester_pressable.dart';
import 'package:mobile/widgets/motion/vibester_shake.dart';

class TertiaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final ButtonState state;

  const TertiaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.state = ButtonState.idle,
  });

  @override
  Widget build(BuildContext context) {
    return VibesterShake(
      trigger: state,
      child: AnimatedContainer(
        duration: context.adaptiveMotion(AppMotion.ui),
        curve: AppMotion.standard,
        width: double.infinity,
        height: 60,
        decoration: BoxDecoration(
          color: state.color(context),
          borderRadius: BorderRadius.circular(30),
          border: state == ButtonState.idle
              ? Border.all(width: 1, color: context.colors.ambar)
              : null,
        ),
        child: VibesterPressable(
          borderRadius: BorderRadius.circular(30),
          onTap: onPressed,
          child: Center(
            child: Text(
              state.label.toUpperCase(),
              style: context.typography.titleMedium.copyWith(
                color: context.colors.textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

enum ButtonState {
  idle,
  loading,
  success,
  error;

  Color color(BuildContext context) => switch (this) {
    ButtonState.idle => context.colors.navy,
    ButtonState.loading => const Color(0xFFFFAA00),
    ButtonState.success => context.colors.ambar,
    ButtonState.error => context.colors.error,
  };

  String get label => switch (this) {
    ButtonState.idle => 'Vou ir',
    ButtonState.loading => 'Carregando...',
    ButtonState.success => 'Interessado',
    ButtonState.error => 'Erro',
  };
}
