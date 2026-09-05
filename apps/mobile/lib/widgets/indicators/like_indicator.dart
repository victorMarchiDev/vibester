import 'package:flutter/material.dart';
import 'package:mobile/models/feed/publication_model.dart';
import 'package:mobile/providers/feed/publication_list_provider.dart';
import 'package:mobile/providers/user/user_provider.dart';
import 'package:mobile/theme/app_motion.dart';
import 'package:mobile/theme/theme_extensions.dart';
import 'package:provider/provider.dart';

/// Curtida com a sequência expressiva pedida na seção 6 do briefing de
/// motion 2.0: o ícone encolhe, cresce, ultrapassa o tamanho final e assenta
/// — não uma simples troca de escala — acompanhado de um pequeno anel que
/// se expande e desaparece, e do contador animando entre os valores.
class LikeIndicator extends StatefulWidget {
  final PublicationModel publication;
  const LikeIndicator({super.key, required this.publication});

  @override
  State<LikeIndicator> createState() => _LikeIndicatorState();
}

class _LikeIndicatorState extends State<LikeIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppMotion.favorite,
  );

  static final _scaleSequence = TweenSequence<double>([
    TweenSequenceItem(
      tween: Tween(
        begin: 1.0,
        end: 0.8,
      ).chain(CurveTween(curve: Curves.easeOut)),
      weight: 25,
    ),
    TweenSequenceItem(
      tween: Tween(
        begin: 0.8,
        end: 1.25,
      ).chain(CurveTween(curve: Curves.easeOut)),
      weight: 40,
    ),
    TweenSequenceItem(
      tween: Tween(
        begin: 1.25,
        end: 1.0,
      ).chain(CurveTween(curve: Curves.easeOutBack)),
      weight: 35,
    ),
  ]);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleLike() {
    final userId = context.read<UserProvider>().user?.accountId;
    if (userId == null) return;
    context.read<PublicationListProvider>().toggleLike(
      widget.publication.id,
      userId,
    );
    if (!widget.publication.isLiked && !context.reduceMotion) {
      // Só "celebra" ao curtir (não ao descurtir).
      _controller.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.publication.isLiked
        ? context.colors.brasa
        : context.colors.textDisabled;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.0),
      child: GestureDetector(
        onTap: _toggleLike,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: context.colors.noturno,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  final ringProgress = _controller.value;
                  return SizedBox(
                    width: 28,
                    height: 28,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        if (ringProgress > 0 && ringProgress < 1)
                          Opacity(
                            opacity: (1 - ringProgress).clamp(0.0, 0.5),
                            child: Transform.scale(
                              scale: 0.8 + ringProgress * 0.9,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: context.colors.brasa,
                                    width: 1.5,
                                  ),
                                ),
                                child: const SizedBox(width: 24, height: 24),
                              ),
                            ),
                          ),
                        Transform.scale(
                          scale: _scaleSequence.evaluate(_controller),
                          child: Icon(Icons.favorite, color: color, size: 24),
                        ),
                      ],
                    ),
                  );
                },
              ),
              SizedBox(width: 10),
              TweenAnimationBuilder<int>(
                tween: IntTween(begin: 0, end: widget.publication.likes),
                duration: context.adaptiveMotion(AppMotion.ui),
                curve: AppMotion.standard,
                builder: (context, value, _) => Text(
                  value.toString(),
                  style: context.typography.titleSmall.copyWith(color: color),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
