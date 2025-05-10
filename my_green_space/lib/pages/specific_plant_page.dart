import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_green_space/utilities/providers.dart';

// This page displays the details of a specific plant selected from the catalog.
class SpecificPlantPage extends ConsumerWidget {
  const SpecificPlantPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plant = ref.watch(selectedPlantProvider);

    return Scaffold(
      appBar: AppBar(title: Text(plant.name)),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Container(
              height: double.infinity,
              width: double.infinity,
              padding: const EdgeInsets.all(40.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20.0),
                child: plant.imageAsset != null && plant.imageAsset!.isNotEmpty
                       ? Image.asset(plant.imageAsset!, fit: BoxFit.cover)
                       : Image.asset("images/No_Image_Available.jpg", fit: BoxFit.cover),
                ),
              ),
            ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 40, right: 40, top: 40),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name
                    Text(
                      plant.name,
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 15),
                    // Description
                    Text(
                      plant.description ?? "No description available",
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 20),
                
                    // Info Sections
                    _buildInfoSection("Plant exposure 🌞", plant.exposure),
                    _buildInfoSection("Optimal temperature range 🌡️", plant.temperatureRange),
                    _buildInfoSection("Transplant period 🌱", plant.transplantPeriod),
                    _buildInfoSection("Harvest period 🌾", plant.harvestPeriod),
                    _buildInfoSection("Irrigation 💧", plant.irrigation),
                                             
                    // Tags
                    if (plant.tags.isNotEmpty)
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 4.0,
                        children:
                            plant.tags
                                .map((tag) => Chip(label: Text(tag)))
                                .toList(),
                      ),                      
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  } // end build method.
} // end SpecificPlantPage.

// Utility widget for section blocks.
Widget _buildInfoSection(String title, dynamic content) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 16.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(
              fontSize: 20, 
              fontWeight: FontWeight.bold,
              fontFamily: 'NotoEmoji',
            )
        ),
        const SizedBox(height: 5),
        Text(
          content != null ? content.toString() : "No information available",
          style: const TextStyle(fontSize: 16),
        ),
      ],
    ),
  );
} // end _buildInfoSection Widget.
