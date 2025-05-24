import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_green_space/pages/add_garden_plant_page.dart';
import 'package:my_green_space/pages/specific_plant_page.dart';
import 'package:my_green_space/utilities/providers.dart';

// A card widget that displays a brief preview of a plant.
// It  allows tapping for open a page with more details.
class PlantPreviewViewer extends ConsumerWidget {
  const PlantPreviewViewer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plant = ref.watch(selectedPlantProvider);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        height: 120,
        child: Row(
          children: [
            // Immagine a sinistra
            Expanded(
              flex: 1,
              child: SizedBox.expand(
                child: plant.imageAsset != null && plant.imageAsset!.isNotEmpty
                    ? Image.asset(plant.imageAsset!, fit: BoxFit.cover)
                    : const Icon(Icons.image_not_supported),
              ),
            ),

            // Contenuto e bottone a destra
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Stack(
                  children: [
                    GestureDetector(
                      onTap: () {
                        // Naviga alla pagina dettagli quando si tocca la parte testuale
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ProviderScope(
                              overrides: [
                                selectedPlantProvider.overrideWithValue(plant),
                              ],
                              child: const SpecificPlantPage(),
                            ),
                          ),
                        );
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            plant.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 15),
                          if (plant.description != null)
                            Text(
                              plant.description!,
                              style: const TextStyle(
                                color: Colors.black54,
                                fontSize: 15,
                              ),
                              maxLines: 15,
                              overflow: TextOverflow.ellipsis,
                            ),
                          const SizedBox(height: 20),
                          Wrap(
                            spacing: 4,
                            runSpacing: 2,
                            children: plant.tags
                                .take(3)
                                .map(
                                  (tag) => Chip(
                                    label: Text(tag, style: const TextStyle(fontSize: 12)),
                                    visualDensity: VisualDensity.compact,
                                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    padding: EdgeInsets.zero,
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                      ),
                    ),

                    // Bottone "Add" posizionato in basso a destra
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.add, size: 16),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          backgroundColor: Colors.green[700],
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ProviderScope(
                                overrides: [
                                  selectedPlantProvider.overrideWithValue(plant),
                                ],
                                child: const AddGardenPlantPage(),
                              ),
                            ),
                          );
                        },
                        label: const Text(
                          "Add",
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
