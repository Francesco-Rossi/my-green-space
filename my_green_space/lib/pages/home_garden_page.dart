import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_green_space/utilities/providers.dart'; // qui c'è gardenPlantsProvider
import 'package:my_green_space/widgets/my_drawer.dart';

class HomeGardenPage extends ConsumerWidget {
  const HomeGardenPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    debugPrint("Building HomeGardenPage...");

    final gardenPlants = ref.watch(gardenPlantsNotifierProvider);

    if (gardenPlants.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Home Garden"),
        ),
        drawer: const MyDrawer(),
        body: const Center(child: Text("No plants found in your garden.")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Home Garden"),
      ),
      drawer: const MyDrawer(),
      body: ListView.builder(
        itemCount: gardenPlants.length,
        itemBuilder: (context, index) {
          final plant = gardenPlants[index];
          return ListTile(
            title: Text(plant.plantType), // assuming plantType is a string
            subtitle: Text('Planted on: ${plant.plantingDate.toLocal().toIso8601String().split('T')[0]}'),
          );
        },
      ),
    );
  }
}
