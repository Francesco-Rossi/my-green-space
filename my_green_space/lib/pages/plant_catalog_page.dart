import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_green_space/pages/add_garden_plant_page.dart';
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
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      appBar: AppBar(title: const Text("Plant Catalog")),
      drawer: const MyDrawer(),
      body: Padding(
        padding: EdgeInsets.only(
          top: isLandscape ? 0.0 : 6.0,
          left: 10,
          right: 10,
        ),
        child: const Column(
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

    final List<Widget> filterChips =
        allTags.map((tag) {
          final isSelected = selectedTags.contains(tag);
          return FilterChip(
            label: Text(tag),
            selected: isSelected,
            selectedColor: Colors.green.shade200,
            backgroundColor: Colors.grey.shade200,
            labelStyle: TextStyle(
              color: isSelected ? Colors.green.shade800 : Colors.black87,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color:
                    isSelected ? Colors.green.shade400 : Colors.grey.shade400,
                width: 1.0,
              ),
            ),
            elevation: isSelected ? 2 : 0,
            onSelected: (bool selected) {
              debugPrint("Tag selected before: $selectedTags");
              final currentTags = [...selectedTags];
              if (selected) {
                currentTags.add(tag);
              } else {
                currentTags.remove(tag);
              }
              ref.read(selectedTagsProvider.notifier).state = currentTags;
              debugPrint("Tag selected after: $currentTags");
            },
          );
        }).toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        const double breakpointWidth = 600.0;

        if (constraints.maxWidth < breakpointWidth) {
          final ScrollController scrollController = ScrollController();

          return Container(
            height: 150,
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Colors.green.shade50.withAlpha(77),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Select tags",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Scrollbar(
                    controller: scrollController,
                    thumbVisibility: true,
                    child: SingleChildScrollView(
                      controller: scrollController,
                      scrollDirection: Axis.vertical,
                      child: Wrap(
                        spacing: 8.0,
                        runSpacing: 6.0,
                        children: filterChips,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        } else {
          final ScrollController scrollController = ScrollController();

          return Container(
            height:
                MediaQuery.of(context).size.height *
                0.2,
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Colors.green.shade50.withAlpha(77),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Select tags",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: MediaQuery.of(context).size.height * 0.03,
                    color: Colors.green,
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                Expanded(
                  child: Scrollbar(
                    controller: scrollController,
                    thumbVisibility: true,
                    child: SingleChildScrollView(
                      controller: scrollController,
                      scrollDirection: Axis.vertical,
                      child: Wrap(
                        spacing: 10.0,
                        runSpacing: 6.0,
                        children: filterChips,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  } // end build method.
} // end _MyTagFilterChips widget.

// A widget that displays the number of filtered (visible) plants.
class _VisiblePlantsCounter extends ConsumerWidget {
  const _VisiblePlantsCounter();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    debugPrint("Building _VisiblePlantsCounter…");

    final filteredPlants = ref.watch(filteredPlantsProvider);
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return filteredPlants.when(
      data:
          (plants) => Text(
            "${plants.length} plants found",
            style: TextStyle(
              fontSize: MediaQuery.of(context).size.height * 0.035,
              fontWeight: FontWeight.bold,
            ),
          ),
      loading:
          () => Text(
            "Loading…",
            style: TextStyle(
              fontSize: isLandscape ? 14 : 16,
              fontStyle: FontStyle.italic,
            ),
          ),
      error:
          (err, _) => Text(
            "Error: no plants found!",
            style: TextStyle(
              fontSize: isLandscape ? 14 : 16,
              color: Colors.red,
            ),
          ),
    );
  } // end build method.
} // end _VisiblePlantsCounter class.

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
      data:
          (filteredPlants) => GridView.builder(
            padding: const EdgeInsets.all(12.0),
            itemCount: filteredPlants.length,
            // We use the grid delegate to define the layout of the grid.
            // In this case, we have three elements per row.
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 450.0,
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
                        builder:
                            (context) => ProviderScope(
                              overrides: [
                                selectedPlantProvider.overrideWithValue(plant),
                              ],
                              child: const SpecificPlantPage(),
                            ),
                      ),
                    );
                  },
                  child: Stack(
                    children: [
                      const PlantPreviewViewer(),
                      Positioned(
                        bottom: 8.0,
                        right: 12.0,
                        child: RawMaterialButton(
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => ProviderScope(
                                      overrides: [
                                        selectedPlantProvider.overrideWithValue(
                                          plant,
                                        ),
                                      ],
                                      child: const AddGardenPlantPage(),
                                    ),
                              ),
                            );
                            if (result && context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Plant added successfully'),
                                ),
                              );
                            }
                          },
                          elevation: 2.0,
                          fillColor: Colors.lightGreen,
                          shape: const CircleBorder(),
                          constraints: const BoxConstraints.tightFor(
                            width: 35,
                            height: 35,
                          ),
                          child: const Icon(Icons.add, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }, // end itemBuilder.
          ),

      // While the data is loading, show a loading spinner.
      loading: () => const Center(child: CircularProgressIndicator()),

      // If an error occurs, show a fallback error message.
      error:
          (error, stackTrace) => const Center(
            child: Text(
              "Error loading plants",
              style: TextStyle(color: Colors.red),
            ),
          ),
    );
  } // end build() method.
} // end PlantGridView.
