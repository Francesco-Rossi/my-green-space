import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
        // height: 120,
        child: Row(
          children: [
            // Image on the left.
            Expanded(
              flex: 1,
              child: SizedBox.expand(
                child:
                    plant.imageAsset != null && plant.imageAsset!.isNotEmpty
                        ? Image.asset(plant.imageAsset!, fit: BoxFit.cover)
                        : const Icon(Icons.image_not_supported),
              ),
            ),

            // Some details on the right.
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Stack(
                  children: [
                    Column(
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
                        // Display some of the tags associated with the plant.
                        Wrap(
                          spacing: 4,
                          runSpacing: 2,
                          children:
                              plant.tags
                                  .take(3)
                                  .map(
                                    (tag) => Chip(
                                      label: Text(
                                        tag,
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                      visualDensity: VisualDensity.compact,
                                      materialTapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                      padding: EdgeInsets.zero,
                                    ),
                                  )
                                  .toList(),
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
    );
  } // end build() method.
} // end PlantPreviewViewer.
