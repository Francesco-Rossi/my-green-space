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

// Homepage that shows a list of things to do, a preview of 
// some plants in the catalog, and a preview of some plants
// of the user.
class Homepage extends ConsumerStatefulWidget {
  const Homepage({super.key});

  @override
  ConsumerState<Homepage> createState() => _HomepageState();
}

class _HomepageState extends ConsumerState<Homepage> {
  late final ScrollController _catalogScrollController;
  late final ScrollController _gardenScrollController;

  List<Plant>? _cachedCatalogPreviewPlants;
  @override
  void initState() {
    super.initState();
    _catalogScrollController = ScrollController();
    _gardenScrollController = ScrollController();
  }

  @override
  void dispose() {
    _catalogScrollController.dispose();
    _gardenScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final plantCatalog = ref.watch(plantCatalogProvider);
    final gardenPlants = ref.watch(gardenPlantsProvider);
    // Providers to handle the local state, that is a list of things to do.
    final todos = ref.watch(todoListProvider);
    final todoNotifier = ref.read(todoListProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('My green space')),
      drawer: const MyDrawer(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with a background image and some text over it.
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
            // Section of things to do.
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.list_alt, size: 28, color: Colors.black),
                  const SizedBox(width: 8),
                  const Text(
                    "Your things to do",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  InkWell(
                    borderRadius: BorderRadius.circular(24),
                    onTap: () {
                      final todoController = TextEditingController();
                      final navigator = Navigator.of(context);
                      final scaffoldMessenger = ScaffoldMessenger.of(context);
                      showDialog(
                        context: context,
                        builder:
                            (dialogContext) => AlertDialog(
                              title: const Text(
                                "Add a new thing to do",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              content: TextField(
                                controller: todoController,
                                autofocus: true,
                                decoration: const InputDecoration(
                                  hintText: "Enter a thing to do",
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () async {
                                    final newTodo = todoController.text.trim();

                                    if (newTodo.isEmpty ||
                                        todos.contains(newTodo)) {
                                      scaffoldMessenger.showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            "The thing to do cannot be empty or duplicated!",
                                          ),
                                        ),
                                      );
                                      return;
                                    }

                                    await todoNotifier.addTodo(newTodo);

                                    if (!mounted) return;

                                    todoController.clear();
                                    navigator.pop();
                                  },
                                  child: const Text("Add"),
                                ),
                              ],
                            ),
                      );
                    },
                    child: const CircleAvatar(
                      backgroundColor: Colors.green,
                      radius: 20,
                      child: Icon(Icons.add, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable list of todos.
            Container(
              padding: const EdgeInsets.all(8.0),
              color: Colors.green.shade50,
              height: 180,
              child:
                  todos.isEmpty
                      ? const Center(
                        child: Text(
                          "No things to do yet. Add one!",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                      : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        scrollDirection: Axis.vertical,
                        itemCount: todos.length,
                        itemBuilder: (context, index) {
                          final scaffoldMessenger = ScaffoldMessenger.of(
                            context,
                          );
                          final todo = todos[index];
                          return Dismissible(
                            key: Key(todo),
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              color: Colors.red,
                              child: const Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                            ),
                            onDismissed: (_) async {
                              await todoNotifier.removeTodo(todo);
                              if (!mounted) return;
                              scaffoldMessenger.showSnackBar(
                                SnackBar(
                                  content: Text("Removed: $todo"),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            },
                            child: Card(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              child: ListTile(title: Text(todo)),
                            ),
                          );
                        },
                      ),
            ),

            const SizedBox(height: 24),

            // Some plants from the catalog are shown as a preview.
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
                  // The cache is populated with some random plants.
                  if (_cachedCatalogPreviewPlants == null) {
                    final random = Random();
                    _cachedCatalogPreviewPlants =
                        (plants.toList()..shuffle(random)).take(5).toList();
                  }
                  final displayPlants = _cachedCatalogPreviewPlants ?? [];

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _buildPlantPreviewList(displayPlants, context),
                      ),
                      const SizedBox(width: 8),
                      TextButton.icon(
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
                          "Go to the catalog",
                          textAlign: TextAlign.start,
                        ),
                      ),
                    ],
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) {
                  _cachedCatalogPreviewPlants = [];
                  const Center(child: Text("Error loading plants"));
                  return const Center(child: Text("Error loading plants"));
                },
              ),
            ),

            const SizedBox(height: 24),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Icon(Icons.local_florist, size: 28, color: Colors.green),
                  SizedBox(width: 8),
                  Text(
                    "Some of your plants",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            // Some plants from the user's catalog are shown as a preview.
            if (gardenPlants.isNotEmpty) ...[
              Container(
                color: Colors.green.shade50,
                height: 180,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Expanded(
                      child: ListView.builder(
                        controller: _gardenScrollController,
                        key: const PageStorageKey('gardenPreviewList'),
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        itemCount: gardenPlants.length.clamp(0, 5),
                        shrinkWrap: true,
                        physics: const ClampingScrollPhysics(),
                        itemBuilder: (context, index) {
                          final plant = gardenPlants[index];

                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => SpecificGardenPlantPage(
                                        plantId: plant.id,
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
                    TextButton.icon(
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HomeGardenPage(),
                          ),
                          (route) => false,
                        );
                      },
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text("Go to your garden"),
                    ),
                  ],
                ),
              ),
            ] else ...[
              Container(
                color: Colors.green.shade50,
                padding: const EdgeInsets.all(16),
                child: const Center(
                  child: Text(
                    "No plants yet",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 24),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const PlantCatalogPage()),
            (route) => false,
          );
        },
        tooltip: "Add a new plant",
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        child: const Icon(Icons.library_add),
      ),
    );
  } // end build method.

  // Preview of the plants in the catalog.
  Widget _buildPlantPreviewList(
    List<Plant> previewPlants,
    BuildContext context,
  ) {
    return SizedBox(
      height: 180,
      width: MediaQuery.of(context).size.width,
      child: ListView.builder(
        controller: _catalogScrollController,
        key: const PageStorageKey('catalogPreviewList'),
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
      ),
    );
  } // end _buildPlantPreviewList widget.
} // end Homepage.
