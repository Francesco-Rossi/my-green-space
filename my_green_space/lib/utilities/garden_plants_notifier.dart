import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_green_space/models/garden_plant.dart';

class GardenPlantsNotifier extends StateNotifier<List<GardenPlant>> {
  GardenPlantsNotifier() : super([]);

  void addPlant(GardenPlant plant) {
    state = [...state, plant]; // crea una nuova lista con la nuova pianta
  }

  void removePlant(String id) {
    state = state.where((plant) => plant.id != id).toList();
  }

  void updatePlant(GardenPlant updatedPlant) {
    state = state.map((plant) {
      if (plant.id == updatedPlant.id) {
        return updatedPlant; 
      }
      return plant; 
    }).toList();
  } // end updatePlant method.

  void clearAll() {
    state = [];
  }
} // end GardenPlantsNotifier class.
