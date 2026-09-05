import 'package:flutter/material.dart';
import 'package:mobile/providers/place/place_list_provider.dart';
import 'package:mobile/theme/theme_extensions.dart';
import 'package:provider/provider.dart';

class LocationPicker extends StatelessWidget {
  const LocationPicker({super.key});

  @override
  Widget build(BuildContext context) {
    final places = context.read<PlaceListProvider>().places;

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Escolha um local',
              style: context.typography.headlineSmall.copyWith(
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 16),

            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: places.length,
                itemBuilder: (context, index) {
                  final place = places[index];

                  return ListTile(
                    leading: const Icon(
                      Icons.location_on,
                      color: Colors.orange,
                    ),
                    title: Text(
                      place.nome,
                      style: context.typography.bodyLarge.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    subtitle: Text(
                      place.categoria,
                      style: context.typography.bodySmall.copyWith(
                        color: Colors.white54,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context, place.nome);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
