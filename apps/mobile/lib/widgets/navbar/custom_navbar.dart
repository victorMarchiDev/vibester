import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:mobile/providers/notification/notification_provider.dart';
import 'package:mobile/theme/app_motion.dart';
import 'package:mobile/theme/theme_extensions.dart';
import 'package:provider/provider.dart';

class CustomNavbar extends StatefulWidget {
  final int? currentIndex;
  final ValueChanged<int>? onTap;

  const CustomNavbar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<CustomNavbar> createState() => _CustomNavbarState();
}

class _CustomNavbarState extends State<CustomNavbar>
    with SingleTickerProviderStateMixin {
  static const _itemCount = 4;
  static const _heartIndex = 2;

  // lowerBound/upperBound precisam cobrir todos os índices (0..3), não o
  // padrão 0.0–1.0 do AnimationController — senão o valor fica limitado em
  // 1.0 e o indicador nunca alcança as posições do coração (2) e do perfil
  // (3). A folga extra (-0.3/+0.3) permite o pequeno overshoot da mola.
  late final AnimationController _indicator = AnimationController(
    vsync: this,
    value: (widget.currentIndex ?? 0).toDouble(),
    lowerBound: -0.3,
    upperBound: _itemCount - 1 + 0.3,
  );

  @override
  void didUpdateWidget(covariant CustomNavbar old) {
    super.didUpdateWidget(old);
    final target = widget.currentIndex?.toDouble();
    if (target != null && target != old.currentIndex?.toDouble()) {
      if (context.reduceMotion) {
        _indicator.value = target;
      } else {
        _indicator.animateWith(
          SpringSimulation(AppMotion.springSmooth, _indicator.value, target, 0),
        );
      }
    }
  }

  @override
  void dispose() {
    _indicator.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = context.watch<NotificationProvider>().unreadCount;

    final items = [
      Icons.home_rounded,
      Icons.search_rounded,
      Icons.favorite_outline_rounded,
      Icons.person_outline_rounded,
    ];

    final activeItems = [
      Icons.home_rounded,
      Icons.search_rounded,
      Icons.favorite_rounded,
      Icons.person_rounded,
    ];

    final circleSize = Platform.isIOS ? 52.0 : 45.0;
    final barHeight = Platform.isIOS ? 70.0 : 65.0;

    return Padding(
      padding: EdgeInsets.only(left: 16, right: 16, bottom: 12, top: 8),
      child: Container(
        height: barHeight,
        decoration: BoxDecoration(
          color: context.colors.navy,
          borderRadius: const BorderRadius.all(Radius.circular(70)),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final slotWidth = constraints.maxWidth / _itemCount;
            return Stack(
              children: [
                // Indicador que viaja fisicamente entre as posições (seção
                // 17), em vez de cada ícone redimensionar no próprio lugar.
                AnimatedBuilder(
                  animation: _indicator,
                  builder: (context, _) {
                    final left =
                        slotWidth * _indicator.value +
                        (slotWidth - circleSize) / 2;
                    return Positioned(
                      left: left,
                      top: (constraints.maxHeight - circleSize) / 2,
                      child: Container(
                        width: circleSize,
                        height: circleSize,
                        decoration: BoxDecoration(
                          color: context.colors.ambar,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: context.colors.ambar.withOpacity(0.4),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(items.length, (index) {
                    final isActive = index == widget.currentIndex;
                    return GestureDetector(
                      onTap: () => widget.onTap!(index),
                      behavior: HitTestBehavior.opaque,
                      child: SizedBox(
                        width: slotWidth,
                        height: barHeight,
                        child: Center(
                          child: AnimatedScale(
                            scale: isActive ? 1.0 : 0.92,
                            duration: context.adaptiveMotion(AppMotion.ui),
                            curve: AppMotion.emphasis,
                            child: _buildIcon(
                              context: context,
                              index: index,
                              isActive: isActive,
                              items: items,
                              activeItems: activeItems,
                              unreadCount: unreadCount,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildIcon({
    required BuildContext context,
    required int index,
    required bool isActive,
    required List<IconData> items,
    required List<IconData> activeItems,
    required int unreadCount,
  }) {
    // Morph outline → filled (seção 18) em vez de trocar instantaneamente.
    final icon = AnimatedSwitcher(
      duration: context.adaptiveMotion(AppMotion.micro),
      transitionBuilder: (child, animation) => ScaleTransition(
        scale: animation,
        child: FadeTransition(opacity: animation, child: child),
      ),
      child: Icon(
        isActive ? activeItems[index] : items[index],
        key: ValueKey(isActive),
        // Ícone ativo fica sobre o círculo context.colors.ambar (cor de marca,
        // fixa nos dois temas), então continua branco; o inativo fica direto
        // sobre context.colors.navy, que agora varia por tema.
        color: isActive ? Colors.white : context.colors.textMuted,
        size: Platform.isIOS ? 26 : 24,
      ),
    );

    if (index != _heartIndex || unreadCount <= 0) {
      return icon;
    }

    final label = unreadCount > 99 ? '99+' : '$unreadCount';

    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        icon,
        Positioned(
          top: 2,
          right: -2,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
            decoration: BoxDecoration(
              color: context.colors.brasa,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: context.colors.navy, width: 1.5),
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: context.typography.labelSmall.copyWith(
                color: Colors.white,
                fontSize: 9,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
