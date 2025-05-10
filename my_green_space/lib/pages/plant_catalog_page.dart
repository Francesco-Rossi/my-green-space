import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_green_space/pages/specific_plant_page.dart';
import 'package:my_green_space/utilities/providers.dart';
import 'package:my_green_space/widgets/my_drawer.dart';
import 'package:my_green_space/widgets/plant_preview_viewer.dart';

// This page displays the plant catalog available in the app as a grid. The user
// can filter the plants by selecting a subset of the tags.
// The selected tags are stored in a  provider and are used to filter the
// plants displayed in the grid. The user can also tap on a plant to view its 
// details in a new specific page.
class PlantCatalogPage extends ConsumerWidget {
  const PlantCatalogPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    debugPrint("Building PlantCatalogPage...");

    return Scaffold(
      appBar: AppBar(title: const Text("Plant Catalog")),
      drawer: const MyDrawer(),
      body: const Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          children: [
            SizedBox(height: 8),
            _MyTagFilterChips(),
            SizedBox(height: 8),
            _VisiblePlantsCounter(),
            SizedBox(height: 8),
            Expanded(child: _PlantGridView()),
          ],
        ),
      ),
    );
  } // end build.
} // end PlantCatalogPage.

// A widget that displays a list of filter chips for all available plant tags.
// Users can select or deselect tags, which are then used to filter the plant catalog.
class _MyTagFilterChips extends ConsumerWidget {
  const _MyTagFilterChips();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    debugPrint("Building MyTagFilterChips...");

    final allTags = ref.watch(allTagsProvider);
    final selectedTags = ref.watch(selectedTagsProvider);

    return Wrap(
      spacing: 8.0,
      runSpacing: 4.0,
      // For each tag, we create a FilterChip widget.
      children:
          allTags.map((tag) {
            final isSelected = selectedTags.contains(tag);
            return FilterChip(
              label: Text(tag),
              selected: isSelected,
              // Function to call when the chip is selected or deselected.
              onSelected: (_) {
                debugPrint("Tag selected before: $selectedTags");
                final currentTags = [...selectedTags];
                if (isSelected) {
                  currentTags.remove(tag);
                } else {
                  currentTags.add(tag);
                }
                // The provider is updated with the new list of selected tags.
                ref.read(selectedTagsProvider.notifier).state = currentTags;
                debugPrint("Tag selected after: $currentTags");
              },
            );
          }).toList(),
    );
  } // end build() method.
} // end MyTagFilterChips.

// A widget that displays the number of filtered (visible) plants.
class _VisiblePlantsCounter extends ConsumerWidget {
  const _VisiblePlantsCounter();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    debugPrint("Building _VisiblePlantsCounter…");

    // filteredPlants could be in different states: loading, error, or data.
    final filteredPlants= ref.watch(filteredPlantsProvider);

    // We use the when() method to handle the different states of the provider.
    return filteredPlants.when(
      // Data uploaded successfully.
      data: (plants) => Text(
        "${plants.length} plants found",
        style: const TextStyle(fontSize: 16),
      ),
      // Loading: show a loading message.
      loading: () => const Text(
        "Loading…",
        style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
      ),
      // Error: show an error message.
      error: (err, _) => const Text(
        "Error: no plants found!",
        style: TextStyle(fontSize: 16, color: Colors.red),
      ),
    );
  } // end build() method.
} // end VisiblePlantsCounter.

// A widget that displays a grid of plant previews. Tapping an item navigates
// to a detailed view of the selected plant.
// The plants displayed are filtered based on the selected tags.
class _PlantGridView extends ConsumerWidget {
  const _PlantGridView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the filtered list of plants.
    final filteredPlants = ref.watch(filteredPlantsProvider);

    // Use the method when() to handle loading, error, and data states.
    return filteredPlants.when(
      // When data is available, display the grid.
      data: (filteredPlants) => GridView.builder(
        padding: const EdgeInsets.all(12.0),
        itemCount: filteredPlants.length,
        // We use the grid delegate to define the layout of the grid.
        // In this case, we have three elements per row.
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 15.0,
          mainAxisSpacing: 5.0,
          childAspectRatio: 0.9,
        ),
        // The itemBuilder function is called for each item in the grid.
        // If an item is tapped, we navigate to the plant detail page using the
        // stack method.
        itemBuilder: (context, index) {
          final plant = filteredPlants[index];

          return ProviderScope(
            overrides: [
              // We override the selected plant provider with the current plant.
              selectedPlantProvider.overrideWithValue(plant),
            ],
            child: GestureDetector(
              onTap: () {
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
              child: const PlantPreviewViewer(),
            ),
          );
        }, // end itemBuilder.
      ),

      // While the data is loading, show a loading spinner.
      loading: () => const Center(child: CircularProgressIndicator()),

      // If an error occurs, show a fallback error message.
      error: (error, stackTrace) => const Center(
        child: Text(
          "Error loading plants",
          style:  TextStyle(color: Colors.red),
        ),
      ),
    );
  } // end build() method.
} // end PlantGridView.

