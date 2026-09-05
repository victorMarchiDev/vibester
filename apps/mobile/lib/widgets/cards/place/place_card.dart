import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mobile/models/place/place_model.dart';
import 'package:mobile/theme/app_motion.dart';
import 'package:mobile/theme/theme_extensions.dart';
import 'package:mobile/utils/hero_tags.dart';
import 'package:mobile/widgets/indicators/category_indicator.dart';
import 'package:mobile/widgets/indicators/movement_indicator.dart';
import 'package:mobile/widgets/indicators/price_indicator.dart';
import 'package:mobile/widgets/motion/vibester_pressable.dart';

class PlaceCard extends StatelessWidget {
  final PlaceModel place;
  final VoidCallback? onTap;

  const PlaceCard({super.key, required this.place, this.onTap});

  @override
  Widget build(BuildContext context) {
    return VibesterPressable(
      onTap: onTap,
      pressScale: AppMotion.scalePress,
      borderRadius: BorderRadius.circular(12),
      child: Card(
        color: context.colors.noturno,
        margin: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: context.colors.grey.withAlpha(80), width: 1),
        ),
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.all(32),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: context.colors.ambar.withOpacity(0.6),
                          blurRadius: 10,
                          offset: const Offset(0, 1),
                          spreadRadius: 2,
                        ),
                      ],
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(25),
                      child: SizedBox(
                        height: 80,
                        width: 80,
                        child: Hero(
                          tag: placeImageHeroTag(place),
                          child: CachedNetworkImage(
                            imageUrl: place.profileImage,
                            fit: BoxFit.cover,
                            fadeInDuration: AppMotion.imageFade,
                            fadeOutDuration: AppMotion.imageFade,
                            placeholder: (_, _) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                            errorWidget: (_, _, _) => const Icon(Icons.error),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          place.nome,
                          style: context.typography.headlineSmall.copyWith(
                            color: context.colors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(Icons.star, color: Colors.yellow, size: 16),
                            SizedBox(width: 4),
                            Text(
                              '${place.avaliacao}',
                              style: context.typography.bodyMedium.copyWith(
                                color: context.colors.textMuted,
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(
                              Icons.circle,
                              color: context.colors.border,
                              size: 6,
                            ),
                            SizedBox(width: 4),
                            PriceIndicator(nivel: place.nivelPrecoMedio),
                          ],
                        ),
                        Text(
                          'Movimento',
                          style: context.typography.titleSmall.copyWith(
                            color: context.colors.textSecondary,
                          ),
                        ),
                        SizedBox(height: 3),
                        MovimentoIndicator(nivel: place.nivelMovimento),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: CategoryIndicator(categoria: place.categoria),
            ),
          ],
        ),
      ),
    );
  }
}
