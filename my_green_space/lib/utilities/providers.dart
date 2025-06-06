import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:my_green_space/models/garden_plant.dart';
import 'package:my_green_space/models/plant.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_green_space/utilities/garden_plants_notifier.dart';
import 'package:my_green_space/utilities/todo_notifier.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Provides the full list of available plants in the catalog asynchronously.
final plantCatalogProvider = FutureProvider<List<Plant>>((ref) async {
  debugPrint("Building plantCatalogProvider..");
  return await Plant.getPlantsCatalog();
}); // end plantCatalogProvider.


// Provides the list of currently active tags for filtering plants.
final selectedTagsProvider = StateProvider<List<String>>((ref) {
  debugPrint("Building selectedTagsProvider..");
  return [];
}); // end selectedTagsProvider.


// Asynchronously provides the list of plants filtered by the currently selected tags.
// If no tags are selected, it returns the full catalog.
final filteredPlantsProvider = FutureProvider<List<Plant>>((ref) async {
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
}); // end filteredPlantsProvider.


// Provides the list of all tags available in the plant catalog.
final allTagsProvider = Provider<List<String>>((ref) {
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
}); // end allTagsProvider.


// This provider holds the currently selected plant of the catalog
// for viewing its details.
final selectedPlantProvider = Provider<Plant>((ref) {
  throw UnimplementedError("No plant selected yet.");
});

// Returns the Supabase client instance.
final supaBaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
}); 

// This provider manages the state of garden plants by a StateNotifier.
// The methods of this class update both the database and the internal state.
final gardenPlantsProvider =
    StateNotifierProvider<GardenPlantsNotifier, List<GardenPlant>>((ref) {
      final supabase = ref.watch(supaBaseClientProvider);
      return GardenPlantsNotifier(supabase);
    }
);

// Provides the list of all plant names in the catalog.
final plantNamesProvider = Provider<List<String>>(
  (ref) {
    debugPrint("Building plantNamesProvider..");

    final catalogAsync = ref.watch(plantCatalogProvider);

    return catalogAsync.when(
      data: (plants) {
        final names = plants.map((plant) => plant.name).toList();
        names.sort(); 
        return names;
      },
      loading: () => [], 
      error: (error, stackTrace) => [], 
    );
  }
);

// Provides the list of currently active plant names for filtering 
// the plants of the user.
final selectedPlantNamesProvider = StateProvider<List<String>>((ref) {
  debugPrint("Building selectedPlantNamesProvider..");
  return [];
}); // end selectedPlantNamesProvider.


// Provides the list of user's garden plants filtered by selected plant names.
final filteredGardenPlantsProvider = Provider<List<GardenPlant>>(
  (ref) {
    debugPrint("Building filteredGardenPlantsProvider...");

    final allGardenPlants = ref.watch(gardenPlantsProvider);
    final selectedNames = ref.watch(selectedPlantNamesProvider);

    if (selectedNames.isEmpty) return allGardenPlants;

    return allGardenPlants
        .where((plant) => selectedNames.contains(plant.plantType))
        .toList();
  }
);

/*
// This provider holds the currently selected plant of the garden user
// for viewing its details.
final selectedGardenPlantProvider = Provider<GardenPlant>((ref) {
  throw UnimplementedError("No garden plant selected yet.");
});
*/

final selectedGardenPlantProvider = Provider.family<GardenPlant?, String>((ref, plantId) {
  final allPlants = ref.watch(gardenPlantsProvider);
  return allPlants.firstWhereOrNull(
    (plant) => plant.id == plantId,
  );
});

// Provider to expose the todo list notifier.
final todoListProvider = StateNotifierProvider<TodoListNotifier, List<String>>(
  (ref) => TodoListNotifier(),
);
