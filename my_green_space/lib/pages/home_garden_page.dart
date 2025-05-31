import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_green_space/pages/specific_garden_plant_page.dart';
import 'package:my_green_space/utilities/providers.dart';
import 'package:my_green_space/widgets/garden_plant_preview_viewer.dart';
import 'package:my_green_space/widgets/my_drawer.dart';

class HomeGardenPage extends ConsumerWidget {
  const HomeGardenPage({super.key});

  // This method is called when the user taps the botton to delete all plants.
  Future<void> _confirmAndDeleteAllPlants(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text(
              'Delete all plants',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: const Text(
              'Are you sure you want to delete all plants from your garden? ',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text(
                  'Delete All',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );

    if (confirm == true) {
      // Call the notifier to clear all plants from the garden.
      await ref.read(gardenPlantsProvider.notifier).clearAll();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All the plants have been deleted from your garden.'),
          ),
        );
      }
    }
  } // end _confirmAndDeleteAllPlants method.

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    debugPrint("Building HomeGardenPage...");

    return Scaffold(
      appBar: AppBar(title: const Text("Home Garden")),
      drawer: const MyDrawer(),
      body: const Padding(
        padding: EdgeInsets.all(12.0),
        child: Column(
          children: [
            SizedBox(height: 8),
            _MyPlantFilterChips(),
            SizedBox(height: 16),
            _VisibleGardenPlantsCounter(),
            SizedBox(height: 8),
            Expanded(child: _GardenPlantGridView()),
          ],
        ),
      ),
      // FloatingActionButton for deleting all plants.
      floatingActionButton: FloatingActionButton(
        onPressed: () => _confirmAndDeleteAllPlants(context, ref),
        backgroundColor: Colors.red[400],
        tooltip: 'Delete all plants',
        child: const Icon(Icons.delete_forever, color: Colors.white),
      ),
    );
  }
} // end HomeGardenPage.

// A widget that displays a list of filter chips for all available plants in
// the catalog.
// Users can select or deselect plants, which are then used to filter the plants
// in the user garden.
class _MyPlantFilterChips extends ConsumerWidget {
  const _MyPlantFilterChips();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    debugPrint("Building MyPlantFilterChips...");

    final allPlantsNames = ref.watch(plantNamesProvider);
    final selectedPlantNames = ref.watch(selectedPlantNamesProvider);

    return Wrap(
      spacing: 10.0,
      runSpacing: 6.0,
      // For each plant's name, we create a FilterChip widget.
      children:
          allPlantsNames.map((name) {
            final isSelected = selectedPlantNames.contains(name);
            return FilterChip(
              label: Text(name),
              selected: isSelected,
              // Function to call when the chip is selected or deselected.
              onSelected: (_) {
                debugPrint("Plant name selected before: $selectedPlantNames");
                final currentPlantNames = [...selectedPlantNames];
                if (isSelected) {
                  currentPlantNames.remove(name);
                } else {
                  currentPlantNames.add(name);
                }
                // The provider is updated with the new list of selected tags.
                ref.read(selectedPlantNamesProvider.notifier).state =
                    currentPlantNames;
                debugPrint("Tag selected after: $currentPlantNames");
              },
            );
          }).toList(),
    );
  } // end build() method.
} // end _MyPlantFilterChips.

class _VisibleGardenPlantsCounter extends ConsumerWidget {
  const _VisibleGardenPlantsCounter();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final visibleCount = ref.watch(filteredGardenPlantsProvider).length;

    return Text(
      "$visibleCount plants found in your garden",
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    );
  } // end build() method.
} // end VisibleGardenPlantsCounter.

class _GardenPlantGridView extends ConsumerWidget {
  const _GardenPlantGridView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    debugPrint("Building GardenPlantGridView...");

    final filteredGardenPlants = ref.watch(filteredGardenPlantsProvider);
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.5,
      ),
      itemCount: filteredGardenPlants.length,
      itemBuilder: (context, index) {
        debugPrint("Building grid item at index: $index");
        final gardenPlant = filteredGardenPlants[index];
        return GestureDetector(
          onTap: () async {
            final deleted = await Navigator.push<bool>(
              context,
              MaterialPageRoute(
                builder:
                    (_) => SpecificGardenPlantPage(plantId: gardenPlant.id),
              ),
            );
            if (deleted == true && context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Plant deleted successfully')),
              );
            }
          },
          child: Stack(
            children: [
              GardenPlantPreviewViewer(plantId: gardenPlant.id),
              Positioned(
                bottom: 8,
                right: 8,
                child: TextButton.icon(
                  onPressed: () async {
                    final bool? confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text(
                          'Delete Plant',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        content: const Text(
                          'Are you sure you want to delete this plant?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(false),
                            child: const Text('Cancel'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(ctx).pop(true);
                            },
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
                      await ref.read(gardenPlantsProvider.notifier)
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
                  label: const Icon(Icons.delete,),
                ),
              ),
            ],
          ),
        );
      },
    );
  } // end build() method.
} // end _GardenPlantGridView.
