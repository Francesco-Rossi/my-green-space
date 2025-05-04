import 'package:my_green_space/models/plant.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provides the full list of available plants in the catalog.
// This data is static and does not change during runtime.
final plantCatalogProvider = Provider<List<Plant>>(
  (ref) {
  return Plant.getPlantsCatalog();
  }
); // end plantCatalogProvider.

// Provides the list of currently active tags for filtering plants.
final selectedTagsProvider = StateProvider<List<String>>(
  (ref) {
    return [];
  }
); // end selectedTagsProvider.

// Provides the filtered list of plants based on the currently selected tags.
final filteredPlantsProvider = Provider<List<Plant>>(
  (ref) {
    final allPlants = ref.watch(plantCatalogProvider);
    final selectedTags = ref.watch(selectedTagsProvider);

    if (selectedTags.isEmpty) {
      return allPlants;
    } 
    else {
      // Only the plants that match all selected tags will be returned.
      return allPlants.where((plant) {
        return selectedTags.every((tag) => plant.tags.contains(tag));
      }).toList();
    }
  }
); // end filteredPlantsProvider.

// Provides the list of all tags available in the plant catalog.
final allTagsProvider = Provider<List<String>>((ref) {
  final allPlants = ref.watch(plantCatalogProvider);
  // We use a set to collect all tags: in this way we avoid duplicates.
  final allTagsSet = <String>{};
  for (var plant in allPlants) {
    allTagsSet.addAll(plant.tags);
  }
  // The set is converted into a list and then sorted alphabetically.
  final allTagsList = allTagsSet.toList()..sort();
  return allTagsList;
});

// This provider holds the currently selected plant of the catalog
// for viewing its details.
final selectedPlantProvider = Provider<Plant>((ref) { 
  throw UnimplementedError("No plant selected yet.");
});