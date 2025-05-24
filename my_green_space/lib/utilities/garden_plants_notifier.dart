import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_green_space/models/garden_plant.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GardenPlantsNotifier extends StateNotifier<List<GardenPlant>> {
  final SupabaseClient supabase;

  GardenPlantsNotifier(this.supabase) : super([]) {
    loadPlants();
  }

  Future<void> loadPlants() async {
    final data = await supabase.from('garden_plants').select();
    state = (data as List<dynamic>)
        .map((e) => GardenPlant.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> addPlant(GardenPlant plant) async {
    final response = await supabase
        .from('garden_plants')
        .insert([plant.toJson()])
        .select()
        .single();

    if (response != null) {
      final newPlant = GardenPlant.fromJson(response);
      state = [...state, newPlant];
    }
  }

  Future<void> removePlant(String id) async {
    await supabase.from('garden_plants').delete().eq('id', id);
    state = state.where((plant) => plant.id != id).toList();
  }

  Future<void> updatePlant(GardenPlant updatedPlant) async {
    final response = await supabase
        .from('garden_plants')
        .update(updatedPlant.toJson())
        .eq('id', updatedPlant.id)
        .select()
        .single();

    if (response != null) {
      state = state.map((plant) {
        if (plant.id == updatedPlant.id) {
          return GardenPlant.fromJson(response);
        }
        return plant;
      }).toList();
    }
  }

  void clearAll() {
    state = [];
  }
}
