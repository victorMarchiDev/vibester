import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile/models/event/event_model.dart';
import 'package:mobile/theme/app_motion.dart';
import 'package:mobile/utils/app_progress_indicator.dart';
import 'package:mobile/utils/hero_tags.dart';
import 'package:mobile/theme/theme_extensions.dart';
import 'package:mobile/widgets/motion/vibester_pressable.dart';

class IWillGoEventCard extends StatelessWidget {
  final EventModel event;
  final VoidCallback? onTap;

  const IWillGoEventCard({super.key, required this.event, this.onTap});

  @override
  Widget build(BuildContext context) {
    return VibesterPressable(
      onTap: onTap,
      pressScale: AppMotion.scalePress,
      borderRadius: BorderRadius.circular(16),
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: context.colors.ambar.withAlpha(50), width: 1),
        ),
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          height: 150,
          child: Container(
            color: context.colors.navy,
            child: Column(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
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
                                errorWidget: (_, _, _) =>
                                    const Icon(Icons.error),
                              ),
                            ),

                            // data
                            Positioned(
                              bottom: 8,
                              left: 8,
                              child: Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: context.colors.navy.withAlpha(150),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: context.colors.ambar,
                                    width: 0,
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      DateFormat("dd", "pt_BR")
                                          .format(event.dataDoEvento)
                                          .toUpperCase(),
                                      style: context.typography.headlineSmall
                                          .copyWith(
                                            fontSize: 19,
                                            color: Colors.white,
                                            height: 1.0,
                                          ),
                                    ),
                                    Text(
                                      DateFormat("MMM", "pt_BR")
                                          .format(event.dataDoEvento)
                                          .toUpperCase(),
                                      style: context.typography.titleSmall
                                          .copyWith(
                                            color: context.colors.ambar,
                                            height: 1.0,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(width: 3),

                      Expanded(
                        flex: 3,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            // Ver evento

                            // Tipo
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: context.colors.ambar.withAlpha(20),
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(
                                    color: context.colors.ambar,
                                    width: 1,
                                  ),
                                ),
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      event.categoria,
                                      style: context.typography.labelSmall
                                          .copyWith(
                                            color: context.colors.ambar,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            Positioned(
                              top: 40,
                              left: 10,
                              child: Container(
                                width: 150,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: context.colors.navy,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            event.titulo.toUpperCase(),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                            style: context
                                                .typography
                                                .labelMedium
                                                .copyWith(
                                                  color: context
                                                      .colors
                                                      .textPrimary,
                                                  height: 1.0,
                                                ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            DateFormat("EEE  HH:mm", "pt_BR")
                                                .format(event.dataDoEvento)
                                                .toUpperCase(),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                            style: context.typography.titleSmall
                                                .copyWith(
                                                  fontSize: 13,
                                                  color: context
                                                      .colors
                                                      .textDisabled,
                                                  height: 1.0,
                                                ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            "Voce confirmou sua presença!",
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                            style: context.typography.labelSmall
                                                .copyWith(
                                                  color: context.colors.ambar,
                                                  height: 1.0,
                                                ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
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
      ),
    );
  }
}
