import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_green_space/providers.dart';

// This page displays the details of a specific plant selected from the catalog.
class SpecificPlantPage extends ConsumerWidget {
  const SpecificPlantPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plant = ref.watch(selectedPlantProvider);

    return Scaffold(
      appBar: AppBar(title: Text(plant.name)),
      body: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (plant.imageAsset != null)
            Expanded(
              child: SizedBox(
                height: double.infinity,
                width: double.infinity,
                child: Image.asset(
                  plant.imageAsset!,
                  fit: BoxFit.cover,
                ),
              ),
            )
          else
            Container(
              height: 250,
              width: double.infinity,
              color: Colors.grey[300],
              child: const Icon(Icons.image_not_supported, size: 60),
            ),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      plant.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
            
                  const SizedBox(height: 8),
            
                  // Description
                  if (plant.description != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        plant.description!,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
            
                  const SizedBox(height: 16),
            
                  if (plant.exposure != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        "Plant exposure: ${plant.exposure}",
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
            
                  const SizedBox(height: 8),
            
                  // Tags
                  if (plant.tags.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Wrap(
                        spacing: 8.0,
                        runSpacing: 4.0,
                        children:
                            plant.tags
                                .map((tag) => Chip(label: Text(tag)))
                                .toList(),
                      ),
                    ),
            
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  } // end build method.
} // end SpecificPlantPage.
