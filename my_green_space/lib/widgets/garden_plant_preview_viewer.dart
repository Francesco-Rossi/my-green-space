import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_green_space/utilities/providers.dart';
import 'package:intl/intl.dart';

// This widget shows a preview of a garden plant with its main photo,
// type, ID, planting date, and some info about photos, watering records, and notes.
// By clicking on the plant card, it is possible to navigate to the specific
// garden plant page, which contains more details.
class GardenPlantPreviewViewer extends ConsumerWidget {
  final String plantId;

  const GardenPlantPreviewViewer({super.key, required this.plantId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    debugPrint("Building GardenPlantPreviewViewer for plant ID: $plantId");
    final gardenPlant = ref.watch(selectedGardenPlantProvider(plantId));
    // Format the planting date to a readable format (String).
    final dateFormatted = DateFormat.yMMMd().format(gardenPlant!.plantingDate);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          // Image on the left side of the card.
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
              child:
                  gardenPlant.mainPhotoUrl != null &&
                          gardenPlant.mainPhotoUrl!.isNotEmpty
                      ? Image.network(
                        gardenPlant.mainPhotoUrl!,
                        fit: BoxFit.cover,
                        height: double.infinity,
                        width: double.infinity,
                        errorBuilder:
                            (_, __, ___) =>
                                const Icon(Icons.image_not_supported, size: 40),
                      )
                      : const Icon(Icons.image_not_supported, size: 40),
            ),
          ),

          // Some details on the right side of the card.
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(
                top: 12,
                bottom: 5,
                left: 12,
                right: 5,
              ),
              child: Stack(
                children: [
                  // Main column with plant info
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Plant type in bold.
                      Text(
                        gardenPlant.plantType,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),
                      // Plant ID in italic and smaller font.
                      Text(
                        'ID: ${gardenPlant.id}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                          fontStyle: FontStyle.italic,
                        ),
                      ),

                      const SizedBox(height: 15),
                      RichText(
                        text: TextSpan(
                          children: [
                            const TextSpan(
                              text: 'Planted on: ',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            TextSpan(
                              text: dateFormatted,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.normal,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 15),
                      // Position of the plant in the garden.
                      RichText(
                        text: TextSpan(
                          children: [
                            const TextSpan(
                              text: 'Position: ',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            TextSpan(
                              text: gardenPlant.position ?? 'Not specified',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.normal,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 50),
                      // Counter of the number of photos, the number watering records and
                      // the number of notes available for that specific garden plant.
                      Row(
                        children: [
                          _InfoIconText(
                            icon: Icons.photo_camera,
                            text: '${gardenPlant.photos?.length ?? 0}',
                          ),
                          const SizedBox(width: 8),
                          _InfoIconText(
                            icon: Icons.water_drop,
                            text: '${gardenPlant.wateringRecords?.length ?? 0}',
                          ),
                          const SizedBox(width: 8),
                          _InfoIconText(
                            icon: Icons.note,
                            text: '${gardenPlant.notes?.length ?? 0}',
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Delete button positioned in the bottom right corner
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.brown),
                      tooltip: 'Delete plant',
                      onPressed: () async {
                        final bool? confirm = await showDialog<bool>(
                          context: context,
                          builder:
                              (ctx) => AlertDialog(
                                title: const Text(
                                  'Delete Plant',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                content: const Text(
                                  'Are you sure you want to delete this plant?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed:
                                        () => Navigator.of(ctx).pop(false),
                                    child: const Text('Cancel'),
                                  ),
                                  ElevatedButton(
                                    onPressed:
                                        () => Navigator.of(ctx).pop(true),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                    ),
                                    child: const Text(
                                      'Delete',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                        );

                        if (confirm == true) {
                          await ref
                              .read(gardenPlantsProvider.notifier)
                              .removePlant(gardenPlant);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Plant deleted successfully'),
                              ),
                            );
                          }
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  } // end build() method.
} // end GardenPlantPreviewViewer.

// Widget that displays an icon and text in a row.
class _InfoIconText extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoIconText({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.green[700]),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 14)),
      ],
    );
  } // end build() method.
} // end _InfoIconText.
