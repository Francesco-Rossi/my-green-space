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

  final storage = supabase.storage;
  const bucketId = 'user-plants-images';
  final folderPath = 'plants/plant_${plantToRemove.id}';

  try {
    // Obtain all files recursively
    final filePaths = await _getAllFilesRecursively(bucketId, folderPath);

    if (filePaths.isNotEmpty) {
      await storage.from(bucketId).remove(filePaths);
      debugPrint("Deleted ${filePaths.length} files associated to ${plantToRemove.id}");
    }
  } catch (e) {
    debugPrint("Error during elimination of files for ${plantToRemove.id}: $e");
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
      // Obtain recursively file inside 'plants/'
      final allFilePaths = await _getAllFilesRecursively(bucketId, rootPath);

      // Delete files found
      if (allFilePaths.isNotEmpty) {
        await storage.from(bucketId).remove(allFilePaths);
        debugPrint(
          "Deleted ${allFilePaths.length} files from Supabase Storage.",
        );
      }

      // Deleting records from the database.
      await supabase
          .from('garden_plants')
          .delete()
          .neq('id', '00000000-0000-0000-0000-000000000000');

      // Clear the local state
      state = [];
    } catch (e, _) {
      debugPrint("Error in clearAll: $e");
    }
  }

  Future<List<String>> _getAllFilesRecursively(
    String bucketId,
    String path,
  ) async {
    final storage = supabase.storage;
    final items = await storage.from(bucketId).list(path: path);
    List<String> files = [];

    for (final item in items) {
      final fullPath = '$path/${item.name}';

      if (item.metadata == null || item.metadata!['mimetype'] == null) {
        final nestedFiles = await _getAllFilesRecursively(bucketId, fullPath);
        files.addAll(nestedFiles);
      } else {
        files.add(fullPath);
        debugPrint('File to delete: $fullPath');
      }
    }

    return files;
  }
} // end GardenPlantsNotifier class.
