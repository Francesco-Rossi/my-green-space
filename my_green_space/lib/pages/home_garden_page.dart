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
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    debugPrint("Building HomeGardenPage...");

    return Scaffold(
      appBar: AppBar(title: const Text("Home Garden")),
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
            _MyPlantFilterChips(),
            SizedBox(height: 8),
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

    final List<Widget> filterChips =
        allPlantsNames.map((name) {
          final isSelected = selectedPlantNames.contains(name);
          return FilterChip(
            label: Text(name),
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
              debugPrint("Plant name selected before: $selectedPlantNames");
              final currentPlantNames = [...selectedPlantNames];
              if (selected) {
                currentPlantNames.add(name);
              } else {
                currentPlantNames.remove(name);
              }
              ref.read(selectedPlantNamesProvider.notifier).state =
                  currentPlantNames;
              debugPrint("Plant name selected after: $currentPlantNames");
            },
          );
        }).toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        const double breakpointWidth = 600.0;

        final ScrollController scrollController = ScrollController();

        final screenHeight = MediaQuery.of(context).size.height;

        return Container(
          height:
              constraints.maxWidth < breakpointWidth ? 150 : screenHeight * 0.2,
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
                "Select plants",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize:
                      constraints.maxWidth < breakpointWidth
                          ? 16
                          : screenHeight * 0.03,
                  color: Colors.green,
                ),
              ),
              SizedBox(
                height:
                    constraints.maxWidth < breakpointWidth
                        ? 8
                        : screenHeight * 0.03,
              ),
              Expanded(
                child: Scrollbar(
                  controller: scrollController,
                  thumbVisibility: true,
                  child: SingleChildScrollView(
                    controller: scrollController,
                    scrollDirection: Axis.vertical,
                    child: Wrap(
                      spacing: 8.0,
                      runSpacing: 5.0,
                      children: filterChips,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  } // end build method.
} // end _MyPlantFilterChips widget.

class _VisibleGardenPlantsCounter extends ConsumerWidget {
  const _VisibleGardenPlantsCounter();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final visibleCount = ref.watch(filteredGardenPlantsProvider).length;

    return Text(
      "$visibleCount plants found in your garden",
      style: TextStyle(
        fontSize: MediaQuery.of(context).size.height * 0.035,
        fontWeight: FontWeight.bold,
      ),
      textAlign: TextAlign.center,
    );
  } // end build() method.
} // end VisibleGardenPlantsCounter.

class _GardenPlantGridView extends ConsumerWidget {
  const _GardenPlantGridView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    debugPrint("Building GardenPlantGridView...");

    final filteredGardenPlants = ref.watch(filteredGardenPlantsProvider);

    final screenWidth = MediaQuery.of(context).size.width;

    int crossAxisCount;
    if (screenWidth < 680) {
      crossAxisCount = 1;
    } else if (screenWidth < 980) {
      crossAxisCount = 2;
    } else {
      crossAxisCount = 3;
    }

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 12.0,
        mainAxisSpacing: 12.0,
        childAspectRatio: 1.0,
      ),
      itemCount: filteredGardenPlants.length,
      padding: const EdgeInsets.all(12.0),
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
                right: 5,
                top: 5,
                child: TextButton.icon(
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
                                onPressed: () => Navigator.of(ctx).pop(false),
                                child: const Text('Cancel'),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.of(ctx).pop(true),
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
                  label: const Icon(Icons.delete, color: Colors.redAccent),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
