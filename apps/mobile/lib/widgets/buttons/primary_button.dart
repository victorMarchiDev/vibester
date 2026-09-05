import 'package:flutter/material.dart';
import 'package:mobile/theme/app_motion.dart';
import 'package:mobile/theme/theme_extensions.dart';
import 'package:mobile/widgets/motion/vibester_pressable.dart';
import 'package:mobile/widgets/motion/vibester_shake.dart';

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final ButtonState state;

  const PrimaryButton({
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
        width: 350,
        height: 60,
        decoration: BoxDecoration(
          color: state.color(context),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: context.colors.ambar.withOpacity(0.5),
              blurRadius: 12,
              spreadRadius: 1,
            ),
            BoxShadow(
              color: context.colors.ambar.withOpacity(0.3),
              blurRadius: 20,
              spreadRadius: 1,
            ),
            BoxShadow(
              color: context.colors.ambar.withOpacity(0.15),
              blurRadius: 30,
              spreadRadius: 1,
            ),
          ],
        ),
        child: VibesterPressable(
          borderRadius: BorderRadius.circular(30),
          onTap: onPressed,
          child: Center(
            child: Text(
              state == ButtonState.idle ? label : state.label,
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
    ButtonState.idle => context.colors.ambar,
    ButtonState.loading => const Color(0xFFFFAA00),
    ButtonState.success => context.colors.navy,
    ButtonState.error => context.colors.error,
  };

  String get label => switch (this) {
    ButtonState.idle => 'Seguir',
    ButtonState.loading => 'Carregando...',
    ButtonState.success => 'Seguindo',
    ButtonState.error => 'Erro',
  };
}
