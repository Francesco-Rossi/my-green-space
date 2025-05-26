import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_green_space/pages/specific_garden_plant_page.dart';
import 'package:my_green_space/utilities/providers.dart';
import 'package:my_green_space/widgets/garden_plant_preview_viewer.dart';
import 'package:my_green_space/widgets/my_drawer.dart';

class HomeGardenPage extends ConsumerWidget {
  const HomeGardenPage({super.key});

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
    );
  }
}

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
        final gardenPlant = filteredGardenPlants[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (_) => SpecificGardenPlantPage(plantId: gardenPlant.id),
              ),
            );
          },
          child: GardenPlantPreviewViewer(plantId: gardenPlant.id),
        );
      },
    );
  } // end build() method.
} // end _GardenPlantGridView.
