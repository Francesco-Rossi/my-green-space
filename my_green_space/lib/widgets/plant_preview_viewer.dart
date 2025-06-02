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
                      // mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          plant.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 15),
                        if (plant.description != null)
                          LayoutBuilder(
                            builder: (
                              BuildContext context,
                              BoxConstraints constraints,
                            ) {
                              int maxLinesDescription;
                              // debugPrint("SCREEN: ${constraints.maxWidth}");
                              // Adapting the number of lines based on the width of the screen
                              if (constraints.maxWidth < 100) {
                                maxLinesDescription = 4;
                              } else if (constraints.maxWidth < 150) {
                                maxLinesDescription = 8;
                              } else {
                                maxLinesDescription = 13;
                              }
                              return Text(
                                plant.description!,
                                style: const TextStyle(
                                  color: Colors.black54,
                                  fontSize: 15,
                                ),
                                maxLines: maxLinesDescription,
                                overflow: TextOverflow.ellipsis,
                              );
                            },
                          ),
                        const SizedBox(height: 20),
                        // Display of some tags associated to  the plant.
                        Wrap(
                          spacing: 4.0,
                          runSpacing: 4.0,
                          children:
                              plant.tags.take(2).map((tag) {
                                return Chip(
                                  label: Text(
                                    tag,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                  backgroundColor: Colors.green.shade300,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  visualDensity: VisualDensity.compact,
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 0,
                                  ),
                                );
                              }).toList(),
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
