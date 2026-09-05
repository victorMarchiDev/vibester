import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile/models/event/event_model.dart';
import 'package:mobile/theme/app_motion.dart';
import 'package:mobile/theme/theme_extensions.dart';
import 'package:mobile/utils/app_progress_indicator.dart';
import 'package:mobile/utils/hero_tags.dart';
import 'package:mobile/widgets/badges/pixel_badge.dart';
import 'package:mobile/widgets/motion/vibester_pressable.dart';

class EventCard extends StatelessWidget {
  final EventModel event;
  final VoidCallback? onTap;

  const EventCard({super.key, required this.event, this.onTap});

  @override
  Widget build(BuildContext context) {
    return VibesterPressable(
      onTap: onTap,
      pressScale: AppMotion.scalePress,
      borderRadius: BorderRadius.circular(16),
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          height: 200,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Hero(
                tag: eventImageHeroTag(event),
                child: CachedNetworkImage(
                  imageUrl: event.imageUrl,
                  fit: BoxFit.cover,
                  fadeInDuration: AppMotion.imageFade,
                  fadeOutDuration: AppMotion.imageFade,
                  placeholder: (_, _) =>
                      const Center(child: AppProgressIndicator()),
                  errorWidget: (_, _, _) => const Icon(Icons.error),
                ),
              ),

              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withAlpha(220)],
                  ),
                ),
              ),

              if (event.emDestaque)
                Positioned(
                  top: 12,
                  left: 12,
                  child: PixelBadge(label: 'Destaque'),
                ),

              //Campos de texto sob a imagem (Estudar melhor essa parta, ta meio confuso algumas partes)
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat(
                        "EEE dd MMM  HH:mm",
                        "pt_BR",
                      ).format(event.dataDoEvento).toUpperCase(),
                      style: context.typography.labelMedium.copyWith(
                        color: context.colors.brasa,
                      ),
                    ),
                    Text(
                      event.titulo.toUpperCase(),
                      style: context.typography.headlineMedium.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      event.artistas,
                      style: context.typography.titleMedium.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: context.colors.brasa,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.info, color: Colors.white, size: 24),
                          SizedBox(width: 8),
                          Text(
                            "MAIS INFORMAÇÕES",
                            textAlign: TextAlign.center,
                            style: context.typography.titleMedium.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
