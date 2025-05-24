import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_green_space/pages/add_garden_plant_page.dart';
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
              //height: double.infinity,
              //width: double.infinity,
              padding: const EdgeInsets.all(40.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20.0),
                child:
                    plant.imageAsset != null && plant.imageAsset!.isNotEmpty
                        ? Image.asset(plant.imageAsset!, fit: BoxFit.cover)
                        : Image.asset(
                          "images/No_Image_Available.jpg",
                          fit: BoxFit.cover,
                        ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 40, right: 40, top: 40),
              child: Column(
                children: [
                  Expanded(
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
                          _buildInfoSection(
                            "Plant exposure",
                            plant.exposure,
                            const Icon(Icons.wb_sunny, color: Colors.orange),
                          ),
                          _buildInfoSection(
                            "Optimal temperature range",
                            plant.temperatureRange,
                            const Icon(
                              Icons.thermostat,
                              color: Colors.redAccent,
                            ),
                          ),
                          _buildInfoSection(
                            "Transplant period",
                            plant.transplantPeriod,
                            const Icon(
                              Icons.calendar_today,
                              color: Colors.blue,
                            ),
                          ),
                          _buildInfoSection(
                            "Harvest period",
                            plant.harvestPeriod,
                            const Icon(
                              Icons.local_florist,
                              color: Colors.green,
                            ),
                          ),
                          _buildInfoSection(
                            "Irrigation",
                            plant.irrigation,
                            const Icon(
                              Icons.water_drop,
                              color: Colors.blueAccent,
                            ),
                          ),

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
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final scaffoldMessenger = ScaffoldMessenger.of(context);
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => ProviderScope(
                                overrides: [
                                  selectedPlantProvider.overrideWithValue(
                                    plant,
                                  ),
                                ],
                                child: const AddGardenPlantPage(),
                              ),
                        ),
                      );
                      // If the user successfully adds the plant to its garden,
                      // a feedback message is shown.
                      if (result == true) {
                        scaffoldMessenger.showSnackBar(
                          SnackBar(
                            content: const Row(
                              children: [
                                Icon(Icons.check_circle, color: Colors.white),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Text('Plant added successfully to your garden!'),
                                ),
                              ],
                            ),
                            duration: const Duration(seconds: 3),
                            backgroundColor: Colors.green[700],
                            behavior:
                                SnackBarBehavior
                                    .floating, // SnackBar flottante con ombra
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            margin: const EdgeInsets.all(
                              16,
                            ), // margine per staccarlo dai bordi
                            elevation: 6, // un po' d'ombra in più
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.add, size: 20),
                    label: const Text(
                      "Add to my garden",
                      style: TextStyle(fontSize: 18),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                      backgroundColor: Colors.green[700],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  } // end build method.
} // end SpecificPlantPage.

// Utility widget for section blocks.
Widget _buildInfoSection(String title, dynamic content, Icon icon) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 16.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),
            icon,
          ],
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
