import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:my_green_space/models/garden_plant.dart';
import 'package:my_green_space/utilities/providers.dart';
import 'package:my_green_space/utilities/support_types.dart';

// This page displays detailed information about a specific garden plant,
// including its photo, notes, watering records, and evolution photos.
// It allows users to edit the plant's position, add notes, and manage
// watering records.
// This page is built through a family provider that takes a plant ID as an argument,
// allowing it to display the correct plant details based on the ID passed.
class SpecificGardenPlantPage extends ConsumerStatefulWidget {
  final String plantId;
  const SpecificGardenPlantPage({required this.plantId, super.key});

  @override
  ConsumerState<SpecificGardenPlantPage> createState() =>
      _SpecificGardenPlantPageState();
}

class _SpecificGardenPlantPageState
    extends ConsumerState<SpecificGardenPlantPage> {
  late final ScrollController _notesScrollController;
  late final ScrollController _wateringScrollController;

  // Initialize the scroll controllers for notes and watering records.
  @override
  void initState() {
    super.initState();
    _notesScrollController = ScrollController();
    _wateringScrollController = ScrollController();
  }

  // Dispose of the scroll controllers to free up resources.
  @override
  void dispose() {
    _notesScrollController.dispose();
    _wateringScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch the specific garden plant provider to get the details of the plant.
    final plant = ref.watch(selectedGardenPlantProvider(widget.plantId));

    return Scaffold(
      appBar: AppBar(title: Text('My ${plant.plantType}')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            // On the left side, display the main photo of the plant.
            Expanded(
              flex: 4,
              child: Column(
                children: [
                  Expanded(
                    child: plant.mainPhotoUrl != null &&
                            plant.mainPhotoUrl!.isNotEmpty
                        ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            plant.mainPhotoUrl!,
                            fit: BoxFit.cover,
                            height: double.infinity,
                            errorBuilder:
                                (_, __, ___) => const Icon(
                                  Icons.image_not_supported,
                                  size: 40,
                                ),
                          ),
                        )
                        : const Center(
                          child: Icon(Icons.image_not_supported, size: 40),
                        ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: pickImage,
                    icon: const Icon(Icons.upload),
                    label: const Text("Change Image"),
                  ),
                ],
              ),
            ),

            Expanded(
              flex: 6,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plant.plantType,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'ID: ${plant.id}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Planted on: ${DateFormat.yMMMd().format(plant.plantingDate)}',
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Position: ${plant.position ?? 'Not specified'}',
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit_location_alt),
                          onPressed:
                              () => _editPositionDialog(context, ref, plant),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      "Notes",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 180,
                      child: Scrollbar(
                        controller: _notesScrollController,
                        child: ListView.builder(
                          controller: _notesScrollController,
                          itemCount: plant.notes?.length ?? 0,
                          itemBuilder: (context, index) {
                            final note = plant.notes![index];
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              child: ListTile(
                                title: Text(note),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit),
                                      onPressed:
                                          () => _editNoteDialog(
                                            context,
                                            ref,
                                            plant,
                                            index,
                                            note,
                                          ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete),
                                      onPressed:
                                          () => _confirmDeleteNote(
                                            context,
                                            ref,
                                            plant,
                                            index,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => _addNoteDialog(context, ref, plant),
                      icon: const Icon(Icons.add),
                      label: const Text("Add Note"),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      "Watering Records",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 150,
                      child: Scrollbar(
                        controller: _wateringScrollController,
                        child: ListView.builder(
                          controller: _wateringScrollController,
                          itemCount: plant.wateringRecords?.length ?? 0,
                          itemBuilder: (context, index) {
                            final record = plant.wateringRecords![index];
                            return ListTile(
                              leading: const Icon(
                                Icons.water_drop,
                                color: Colors.blue,
                              ),
                              title: Text(
                                DateFormat.yMMMd().format(record.date),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => _addWateringRecord(ref, plant),
                      icon: const Icon(Icons.add),
                      label: const Text("Add Watering"),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      "Evolution Photos",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 120,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: plant.photos?.length ?? 0,
                        itemBuilder: (context, index) {
                          final photoUrl = plant.photos![index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4.0,
                            ),
                            child: Image.network(
                              photoUrl.imageUrl,
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                          );
                        },
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        // TODO: implementa l'aggiunta di una foto
                      },
                      icon: const Icon(Icons.add_a_photo),
                      label: const Text("Add Photo"),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _editNoteDialog(
    BuildContext context,
    WidgetRef ref,
    GardenPlant plant,
    int index,
    String oldNote,
  ) {
    final controller = TextEditingController(text: oldNote);
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Edit Note'),
            content: TextField(controller: controller),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  final navigator = Navigator.of(context);
                  final List<String> updatedNotes = [...plant.notes!];
                  updatedNotes[index] = controller.text;
                  final updatedPlant = plant.copyWith(notes: updatedNotes);
                  await ref
                      .read(gardenPlantsProvider.notifier)
                      .updatePlant(updatedPlant);
                  navigator.pop();
                },
                child: const Text('Save'),
              ),
            ],
          ),
    );
  }

  void _confirmDeleteNote(
    BuildContext context,
    WidgetRef ref,
    GardenPlant plant,
    int index,
  ) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Delete Note'),
            content: const Text('Are you sure you want to delete this note?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  final navigator = Navigator.of(context);
                  final List<String> updatedNotes = [...plant.notes!];
                  updatedNotes.removeAt(index);
                  final updatedPlant = plant.copyWith(notes: updatedNotes);
                  await ref
                      .read(gardenPlantsProvider.notifier)
                      .updatePlant(updatedPlant);
                  navigator.pop();
                },
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }

  void _addNoteDialog(BuildContext context, WidgetRef ref, GardenPlant plant) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Add Note'),
            content: TextField(controller: controller),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  final navigator = Navigator.of(context);
                  final List<String> updatedNotes = [
                    ...plant.notes ?? [],
                    controller.text,
                  ];
                  final updatedPlant = plant.copyWith(notes: updatedNotes);
                  await ref
                      .read(gardenPlantsProvider.notifier)
                      .updatePlant(updatedPlant);
                  navigator.pop();
                },
                child: const Text('Add'),
              ),
            ],
          ),
    );
  }

  void _editPositionDialog(
    BuildContext context,
    WidgetRef ref,
    GardenPlant plant,
  ) {
    final controller = TextEditingController(text: plant.position ?? "");
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Edit Position'),
            content: TextField(controller: controller),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  final updatedPlant = plant.copyWith(
                    position: controller.text,
                  );
                  await ref
                      .read(gardenPlantsProvider.notifier)
                      .updatePlant(updatedPlant);
                  Navigator.pop(context);
                },
                child: const Text('Save'),
              ),
            ],
          ),
    );
  }

  void _addWateringRecord(WidgetRef ref, GardenPlant plant) async {
    final List<WateringRecord> updatedRecords = [
      ...plant.wateringRecords ?? [],
      WateringRecord(date: DateTime.now()),
    ];
    final updatedPlant = plant.copyWith(wateringRecords: updatedRecords);
    await ref.read(gardenPlantsProvider.notifier).updatePlant(updatedPlant);
  }

  Future<void> pickImage() async {
    final plant = ref.read(selectedGardenPlantProvider(widget.plantId));

    // L'utente seleziona un file immagine
    final result = await FilePicker.platform.pickFiles(type: FileType.image);

    if (result != null && result.files.single.bytes != null) {
      final imageBytes = result.files.single.bytes!;
      final newUrl = await GardenPlant.uploadImage(
        imageBytes: imageBytes,
        imageType: 'profile',
        plantId: widget.plantId,
        fileName: "${plant.plantType}_${widget.plantId}",
      );

      // Se upload ha successo, aggiorna il provider
      if (newUrl != null) {
        final updatedPlant = plant.copyWith(mainPhotoUrl: newUrl);
        await ref.read(gardenPlantsProvider.notifier).updatePlant(updatedPlant);
      } 
    } 
  }
}
