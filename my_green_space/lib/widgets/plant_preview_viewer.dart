import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_green_space/providers.dart';

// A card widget that displays a brief preview of a plant.
// It  allows tapping for open a page with more details.
class PlantPreviewViewer extends ConsumerWidget {
  const PlantPreviewViewer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plant = ref.watch(selectedPlantProvider);
    if (plant == null) {
      return const SizedBox.shrink(); 
    }
    
    return GestureDetector(
      onTap: () {},
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            Expanded(
              child: Image.asset(
                  plant.imageAsset!),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                plant.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ], 
        ),
      ),
    );
  } // end build() method.
} // end PlantPreviewViewer.
