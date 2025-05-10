import 'package:flutter/material.dart';
import 'package:my_green_space/models/plant.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provides the full list of available plants in the catalog asynchronously.
final plantCatalogProvider = FutureProvider<List<Plant>>(
  (ref) async {
    debugPrint("Building plantCatalogProvider..");
    return await Plant.getPlantsCatalog();
  },
); // end plantCatalogProvider.

// Provides the list of currently active tags for filtering plants.
final selectedTagsProvider = StateProvider<List<String>>(
  (ref) {
    debugPrint("Building selectedTagsProvider..");
    return [];
  }
); // end selectedTagsProvider.

// Asynchronously provides the list of plants filtered by the currently selected tags.
// If no tags are selected, it returns the full catalog.
final filteredPlantsProvider = FutureProvider<List<Plant>>(
  (ref) async {
    debugPrint("Building filteredPlantsProvider..");
    // await Future.delayed(const Duration(seconds: 5));
    final allPlants = await ref.watch(plantCatalogProvider.future);
    final selectedTags = ref.watch(selectedTagsProvider);

    if (selectedTags.isEmpty) {
      return allPlants;
    } else {
      return allPlants
          .where((plant) => selectedTags.every((tag) => plant.tags.contains(tag)))
          .toList();
    }
  }
); // end filteredPlantsProvider.

// Provides the list of all tags available in the plant catalog.
final allTagsProvider = Provider<List<String>>(
  (ref) {
    debugPrint("Building allTagsProvider..");
    // Watch the FutureProvider and handle its AsyncValue state.
    final allPlantsAsync = ref.watch(plantCatalogProvider);

    // If the data is still loading or there is an error, it returns an empty list.
    return allPlantsAsync.when(
      data: (allPlants) {
        // We use a set to collect all tags: in this way we avoid duplicates.
        final allTagsSet = <String>{};
        for (var plant in allPlants) {
          allTagsSet.addAll(plant.tags);
        }
        // The set is converted into a list and then sorted alphabetically.
        final allTagsList = allTagsSet.toList()..sort();
        return allTagsList;
      },
      loading: () => [], // Return an empty list while loading
      error: (error, stackTrace) => [], // Return an empty list in case of error
    );
  }
); // end allTagsProvider. 

// This provider holds the currently selected plant of the catalog
// for viewing its details.
final selectedPlantProvider = Provider<Plant>(
  (ref) { 
    throw UnimplementedError("No plant selected yet.");
  }
);