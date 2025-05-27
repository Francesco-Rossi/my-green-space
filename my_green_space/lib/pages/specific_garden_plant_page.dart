import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:my_green_space/models/garden_plant.dart';
import 'package:my_green_space/utilities/providers.dart';
import 'package:my_green_space/utilities/support_types.dart';

// This page displays detailed information about a specific garden plant.
// It allows users to view and manage the plant's details, including notes,
// watering records, and photos.
// It takes in input the plant ID to fetch the specific plant data from the
// family provider of garden plants.
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
    // Watch the specific garden plant provider to get the current plant data.
    final plant = ref.watch(selectedGardenPlantProvider(widget.plantId));

    return Scaffold(
      appBar: AppBar(title: Text('My ${plant.plantType}')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            // Left side: Plant image and change image button.
            Expanded(
              flex: 4,
              child: Column(
                children: [
                  Expanded(
                    child:
                        plant.mainPhotoUrl != null &&
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
            // Right side: Plant details, notes, watering records, and photos.
            Expanded(
              flex: 6,
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.only(left: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Display the plant type and ID.
                          Text(
                            plant.plantType,
                            style: const TextStyle(
                              fontSize: 30,
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
                          const SizedBox(height: 25),
                          // Display the planting date in a formatted way.
                          RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                              children: [
                                const TextSpan(
                                  text: 'Planted on: ',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                TextSpan(
                                  text: DateFormat.yMMMd().format(
                                    plant.plantingDate,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Display the position of the plant with an edit button.
                          Row(
                            children: [
                              Expanded(
                                child: RichText(
                                  text: TextSpan(
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.black,
                                    ),
                                    children: [
                                      const TextSpan(
                                        text: 'Position: ',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      TextSpan(
                                        text: plant.position ?? 'Not specified',
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit_location_alt),
                                onPressed:
                                    () => _editPositionDialog(
                                      context,
                                      ref,
                                      plant,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 30),
                          _buildSection(
                            title: 'Notes',
                            count: plant.notes?.length ?? 0,
                            icon: Icons.note,
                            child: SizedBox(
                              height: 180,
                              child: Scrollbar(
                                controller: _notesScrollController,
                                child: ListView.builder(
                                  controller: _notesScrollController,
                                  itemCount: plant.notes?.length ?? 0,
                                  itemBuilder: (context, index) {
                                    final note = plant.notes![index];
                                    return Card(
                                      margin: const EdgeInsets.symmetric(
                                        vertical: 4,
                                      ),
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
                            action: TextButton.icon(
                              onPressed:
                                  () => _addNoteDialog(context, ref, plant),
                              icon: const Icon(Icons.add),
                              label: const Text("Add Note"),
                            ),
                          ),
                          _buildSection(
                            title: 'Watering Records',
                            count: plant.wateringRecords?.length ?? 0,
                            icon: Icons.water_drop,
                            child: SizedBox(
                              height: 150,
                              child: Scrollbar(
                                controller: _wateringScrollController,
                                child: ListView.builder(
                                  controller: _wateringScrollController,
                                  itemCount: plant.wateringRecords?.length ?? 0,
                                  itemBuilder: (context, index) {
                                    final record =
                                        plant.wateringRecords![index];
                                    return Card(
                                      margin: const EdgeInsets.symmetric(
                                        vertical: 4,
                                      ),
                                      child: ListTile(
                                        leading: const Icon(
                                          Icons.water_drop,
                                          color: Colors.blue,
                                        ),
                                        title: Text(
                                          DateFormat.yMMMd().format(
                                            record.date,
                                          ),
                                        ),
                                        // ignore: unnecessary_null_comparison
                                        subtitle:
                                            record.amount != null
                                                ? Text(
                                                  'Water: ${record.amount} ml',
                                                )
                                                : null,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            action: TextButton.icon(
                              onPressed:
                                  () => _addWateringRecordDialog(
                                    context,
                                    ref,
                                    plant,
                                  ),
                              icon: const Icon(Icons.add),
                              label: const Text("Add Watering"),
                            ),
                          ),
                          _buildSection(
                            title: 'Evolution Photos',
                            count: plant.photos?.length ?? 0,
                            icon: Icons.photo,
                            child: SizedBox(
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
                            action: TextButton.icon(
                              onPressed: () {
                                final scaffoldMessenger = ScaffoldMessenger.of(
                                  context,
                                );
                                final filePickerFuture = FilePicker.platform
                                    .pickFiles(type: FileType.image);

                                filePickerFuture.then((result) {
                                  if (result == null ||
                                      result.files.single.path == null)
                                    return;

                                  final imagePath = result.files.single.path!;
                                  final noteController =
                                      TextEditingController();

                                  showDialog<bool>(
                                    context: context, // <-- usato subito
                                    builder:
                                        (dialogContext) => AlertDialog(
                                          title: const Text('Add Photo Note'),
                                          content: TextField(
                                            controller: noteController,
                                            decoration: const InputDecoration(
                                              labelText: 'Optional note',
                                            ),
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed:
                                                  () => Navigator.of(
                                                    dialogContext,
                                                  ).pop(false),
                                              child: const Text('Cancel'),
                                            ),
                                            ElevatedButton(
                                              onPressed:
                                                  () => Navigator.of(
                                                    dialogContext,
                                                  ).pop(true),
                                              child: const Text('Add Photo'),
                                            ),
                                          ],
                                        ),
                                  ).then((confirmed) async {
                                    if (confirmed != true) return;

                                    final newPhoto = PlantPhoto(
                                      imageUrl: imagePath,
                                      dateTaken: DateTime.now(),
                                      note:
                                          noteController.text.trim().isNotEmpty
                                              ? noteController.text.trim()
                                              : null,
                                    );

                                    final updatedPhotos = [
                                      ...plant.photos ?? [],
                                      newPhoto,
                                    ];
                                    final updatedPlant = plant.copyWith(
                                      photos: updatedPhotos,
                                    );

                                    await ref
                                        .read(gardenPlantsProvider.notifier)
                                        .updatePlant(updatedPlant);

                                    scaffoldMessenger.showSnackBar(
                                      const SnackBar(
                                        content: Text('Photo added'),
                                      ),
                                    );
                                  });
                                });
                              },

                              icon: const Icon(Icons.add_a_photo),
                              label: const Text("Add Photo"),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () => _confirmDeletePlant(context, ref, plant),
                    icon: const Icon(Icons.delete),
                    label: const Text('Delete'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> pickImage() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;
      final imageUrl = file.path; // Può essere caricato su cloud o locale
      final plant = ref.read(selectedGardenPlantProvider(widget.plantId));
      final updated = plant.copyWith(mainPhotoUrl: imageUrl);
      await ref.read(gardenPlantsProvider.notifier).updatePlant(updated);
    }
  }

  Future<void> _editNoteDialog(
    BuildContext context,
    WidgetRef ref,
    GardenPlant plant,
    int index,
    String oldNote,
  ) async {
    final controller = TextEditingController(text: oldNote);
    await showDialog(
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
                  final newNote = controller.text;
                  final updatedNotes = [...plant.notes!];
                  updatedNotes[index] = newNote;
                  final updated = plant.copyWith(notes: updatedNotes);
                  await ref
                      .read(gardenPlantsProvider.notifier)
                      .updatePlant(updated);
                  if (context.mounted) Navigator.pop(context);
                },
                child: const Text('Save'),
              ),
            ],
          ),
    );
  }

  Future<void> _addNoteDialog(
    BuildContext context,
    WidgetRef ref,
    GardenPlant plant,
  ) async {
    final controller = TextEditingController();
    await showDialog(
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
                  final newNote = controller.text;
                  final List<String> updatedNotes = [
                    ...plant.notes ?? [],
                    newNote,
                  ];
                  final updated = plant.copyWith(notes: updatedNotes);
                  await ref
                      .read(gardenPlantsProvider.notifier)
                      .updatePlant(updated);
                  if (context.mounted) Navigator.pop(context);
                },
                child: const Text('Add'),
              ),
            ],
          ),
    );
  }

  Future<void> _confirmDeleteNote(
    BuildContext context,
    WidgetRef ref,
    GardenPlant plant,
    int index,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Delete Note'),
            content: const Text('Are you sure you want to delete this note?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Delete'),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      final updatedNotes = [...plant.notes!..removeAt(index)];
      final updated = plant.copyWith(notes: updatedNotes);
      await ref.read(gardenPlantsProvider.notifier).updatePlant(updated);
    }
  }

  Future<void> _editPositionDialog(
    BuildContext context,
    WidgetRef ref,
    GardenPlant plant,
  ) async {
    final controller = TextEditingController(text: plant.position ?? '');
    await showDialog(
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
                  final updated = plant.copyWith(
                    position: controller.text.trim(),
                  );
                  await ref
                      .read(gardenPlantsProvider.notifier)
                      .updatePlant(updated);
                  if (context.mounted) Navigator.pop(context);
                },
                child: const Text('Save'),
              ),
            ],
          ),
    );
  }

  Future<void> _confirmDeletePlant(
    BuildContext context,
    WidgetRef ref,
    GardenPlant plant,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Delete Plant'),
            content: const Text('Are you sure you want to delete this plant?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Delete'),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      await ref.read(gardenPlantsProvider.notifier).removePlant(plant);
      if (context.mounted) Navigator.pop(context);
    }
  }

  Future<void> _addWateringRecordDialog(
    BuildContext context,
    WidgetRef ref,
    GardenPlant plant,
  ) async {
    final controller = TextEditingController();
    await showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Add Watering Record'),
            content: TextField(
              controller: controller,
              decoration: const InputDecoration(labelText: 'Water amount (ml)'),
              keyboardType: TextInputType.number,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  final double? quantity = double.tryParse(controller.text);
                  final List<WateringRecord> updatedRecords = [
                    ...plant.wateringRecords ?? [],
                    WateringRecord(date: DateTime.now(), amount: quantity ?? 0),
                  ];
                  final GardenPlant updatedPlant = plant.copyWith(
                    wateringRecords: updatedRecords,
                  );
                  await ref
                      .read(gardenPlantsProvider.notifier)
                      .updatePlant(updatedPlant);
                  if (context.mounted) Navigator.pop(context);
                },
                child: const Text('Add'),
              ),
            ],
          ),
    );
  }

  Widget _buildSection({
    required String title,
    required int count,
    required Widget child,
    Widget? action,
    IconData? icon,
  }) {
    return Card(
      color: Colors.yellow[50],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 20, color: Colors.grey[800]),
                  const SizedBox(width: 8),
                ],
                Text(
                  '$title ($count)',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            child,
            const SizedBox(height: 10),
            if (action != null) action,
          ],
        ),
      ),
    );
  }
}
