import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_green_space/models/garden_plant.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// State Notifier for managing the state of garden plants.
// The methods of this class update both the database and the internal state.
class GardenPlantsNotifier extends StateNotifier<List<GardenPlant>> {
  // Supabase client for database operations.
  final SupabaseClient supabase;

  // Constructor that initializes the notifier with a Supabase client
  // and loads the initial list of plants from the database.
  GardenPlantsNotifier(this.supabase) : super([]) {
    loadPlants();
  }

  // Asynchronous method to load plants from the Supabase database.
  // It fetches the data from the 'garden_plants' table and updates the state
  // by casting each json object to a gardenPlant instance.
  Future<void> loadPlants() async {
    final data = await supabase.from('garden_plants').select();
    state =
        (data as List<dynamic>)
            .map((e) => GardenPlant.fromJson(e as Map<String, dynamic>))
            .toList();
  }

  // Method to add a new plant to the database and update the state accordingly.
  Future<void> addPlant(GardenPlant newPlant) async {
    await supabase
        .from('garden_plants')
        .insert([newPlant.toJson()])
        .select()
        .single();
    // Updating the state with the newly added plant.
    state = [...state, newPlant];
  } // end addPlant method.

  // Method to remove a plant from the database and update the state accordingly.
  Future<void> removePlant(GardenPlant plantToRemove) async {
    await supabase.from('garden_plants').delete().eq('id', plantToRemove.id);

    // The following code deletes all images associated with the plant
    // from the Supabase storage.
    final storage = supabase.storage;
    const bucketId = 'user-plants-images';
    final folderPath = 'plants/plant_${plantToRemove.id}';

    final fileList = await storage.from(bucketId).list(path: folderPath);
    final pathsToDelete = fileList.map((f) => '$folderPath/${f.name}').toList();

    if (pathsToDelete.isNotEmpty) {
      await storage.from(bucketId).remove(pathsToDelete);
    }

    state = state.where((plant) => plant.id != plantToRemove.id).toList();
  } // end removePlant method.

  // Method to update an existing plant in the database and update the state accordingly.
  Future<void> updatePlant(GardenPlant updatedPlant) async {
    final response =
        await supabase
            .from('garden_plants')
            .update(updatedPlant.toJson())
            .eq('id', updatedPlant.id)
            .select()
            .single();

    state =
        state.map((plant) {
          if (plant.id == updatedPlant.id) {
            return GardenPlant.fromJson(response);
          }
          return plant;
        }).toList();
  } // end updatePlant method.

  // Method to clear all plants from both the local state and the Supabase database.
  Future<void> clearAll() async {
    final storage = supabase.storage;
    const bucketId = 'user-plants-images';
    const rootPath = 'plants';

    try {
      // Get the list of all files in the root path of the bucket.
      final files = await storage.from(bucketId).list(path: rootPath);

      // Filter out the file paths to delete.
      final List<String> allFilePaths = [];

      for (final item in files) {
        allFilePaths.add('$rootPath/${item.name}');
        debugPrint("File to delete: $rootPath/${item.name}");
      }
      // If there are any files to delete, remove them from the storage.
      if (allFilePaths.isNotEmpty) {
        await storage.from(bucketId).remove(allFilePaths);
      }

      // Remove all plants from the Supabase database.
      await supabase
          .from('garden_plants')
          .delete()
          .neq('id', '00000000-0000-0000-0000-000000000000');

      // Clear the local state.
      state = [];
    } catch (e, _) {
      debugPrint("Error during clearAll: $e");
    }
  } // end clearAll method.
} // end GardenPlantsNotifier class.
