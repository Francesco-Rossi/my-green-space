import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_green_space/models/plant.dart';
import 'package:my_green_space/pages/home_garden_page.dart';
import 'package:my_green_space/pages/plant_catalog_page.dart';
import 'package:my_green_space/pages/specific_garden_plant_page.dart';
import 'package:my_green_space/pages/specific_plant_page.dart';
import 'package:my_green_space/utilities/providers.dart';
import 'package:my_green_space/widgets/my_drawer.dart';

class Homepage extends ConsumerWidget {
  const Homepage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plantCatalog = ref.watch(plantCatalogProvider);
    final gardenPlants = ref.watch(gardenPlantsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My green space')),
      drawer: const MyDrawer(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con immagine di sfondo
            Stack(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 320,
                  child: Image.asset(
                    'images/plant_homepage.jpg',
                    fit: BoxFit.contain,
                  ),
                ),
                Container(
                  width: double.infinity,
                  height: 320,
                  color: Colors.black54.withAlpha(150),
                ),
                const Positioned.fill(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.eco, size: 48, color: Colors.white),
                        SizedBox(height: 8),
                        Text(
                          "Welcome to your green space",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Discover, collect and manage your favorite plants.",
                          style: TextStyle(fontSize: 16, color: Colors.white70),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ==== ANTEPRIMA CATALOGO ====
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Icon(Icons.search, size: 28, color: Colors.black),
                  SizedBox(width: 8),
                  Text(
                    "Some plants you might like...",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            Container(
              color: Colors.green.shade50,
              height: 180,
              child: plantCatalog.when(
                data: (plants) {
                  final random = Random();
                  final previewPlants =
                      (plants.toList()..shuffle(random)).take(5).toList();

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _buildPlantPreviewList(previewPlants, context),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextButton.icon(
                          onPressed: () {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const PlantCatalogPage(),
                              ),
                              (route) => false,
                            );
                          },
                          icon: const Icon(Icons.arrow_forward),
                          label: const Text(
                            "View all plants from the catalog",
                            textAlign: TextAlign.start,
                          ),
                        ),
                      ),
                    ],
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error:
                    (e, _) => const Center(child: Text("Error loading plants")),
              ),
            ),

            const SizedBox(height: 24),

            // ==== ANTEPRIMA PIANTE DELL'UTENTE ====
            if (gardenPlants.isNotEmpty) ...[
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Icon(Icons.local_florist, size: 28, color: Colors.green),
                    SizedBox(width: 8),
                    Text(
                      "Some of your plants",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                color: Colors.green.shade50,
                height: 180,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Expanded(
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        itemCount: gardenPlants.length.clamp(0, 5),
                        itemBuilder: (context, index) {
                          final plant = gardenPlants[index];

                          return GestureDetector(
                            onTap: () {
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => SpecificGardenPlantPage(
                                        plantId: plant.id,
                                      ),
                                ),
                                (route) => false,
                              );
                            },
                            child: Card(
                              margin: const EdgeInsets.all(8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Container(
                                width: 120,
                                padding: const EdgeInsets.all(8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child:
                                            plant.mainPhotoUrl != null
                                                ? Image.network(
                                                  plant.mainPhotoUrl!,
                                                  fit: BoxFit.cover,
                                                  width: double.infinity,
                                                )
                                                : Container(
                                                  color: Colors.green.shade100,
                                                  child: const Center(
                                                    child: Icon(
                                                      Icons.local_florist,
                                                    ),
                                                  ),
                                                ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      plant.plantType,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      plant.position ?? "Unknown position",
                                      style: const TextStyle(fontSize: 10),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Expanded(
                      child: TextButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const HomeGardenPage(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.arrow_forward),
                        label: const Text("View all your plants"),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const PlantCatalogPage()),
            (route) => false,
          );
        },
        icon: const Icon(Icons.add),
        label: const Text("New Plant"),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        tooltip: "Add a new plant to your garden",
      ),
    );
  }

  Widget _buildPlantPreviewList(
    List<Plant> previewPlants,
    BuildContext context,
  ) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      itemCount: previewPlants.length,
      itemBuilder: (context, index) {
        final plant = previewPlants[index];

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (_) => ProviderScope(
                      overrides: [
                        selectedPlantProvider.overrideWithValue(plant),
                      ],
                      child: const SpecificPlantPage(),
                    ),
              ),
            );
          },
          child: Card(
            margin: const EdgeInsets.all(8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Container(
              width: 120,
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child:
                          plant.imageAsset != null
                              ? Image.asset(
                                plant.imageAsset!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                              )
                              : Container(
                                color: Colors.green.shade100,
                                child: const Center(
                                  child: Icon(Icons.local_florist),
                                ),
                              ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    plant.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
