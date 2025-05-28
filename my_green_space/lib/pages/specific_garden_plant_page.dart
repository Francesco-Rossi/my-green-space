import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:my_green_space/models/garden_plant.dart';
import 'package:my_green_space/utilities/providers.dart';
import 'package:my_green_space/utilities/support_types.dart';

// DialogResult for photo actions.
enum _PhotoActionDialogResult { deleted, error, cancelled }

// This page displays details of a specific garden plant,
// including its image, notes, watering records, and evolution photos.
// This page also allows the user to add notes, watering records, and evolution photos,
// as well as change the main image of the plant.
class SpecificGardenPlantPage extends ConsumerStatefulWidget {
  // This page requires a plantId to fetch the specific plant details.
  final String plantId;
  const SpecificGardenPlantPage({required this.plantId, super.key});

  @override
  ConsumerState<SpecificGardenPlantPage> createState() =>
      _SpecificGardenPlantPageState();
}

class _SpecificGardenPlantPageState
    extends ConsumerState<SpecificGardenPlantPage> {
  // Controllers for the scrollable sections of notes and watering records.
  late final ScrollController _notesScrollController;
  late final ScrollController _wateringScrollController;

  // Initialize the scroll controllers.
  @override
  void initState() {
    super.initState();
    _notesScrollController = ScrollController();
    _wateringScrollController = ScrollController();
  }

  // Dispose the scroll controllers to free up resources.
  @override
  void dispose() {
    _notesScrollController.dispose();
    _wateringScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Use the family provider to get the specific garden plant details.
    final myGardenPlant = ref.watch(
      selectedGardenPlantProvider(widget.plantId),
    );

    return Scaffold(
      appBar: AppBar(title: Text('My ${myGardenPlant.plantType}')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            // Left side: Plant image and change image button.
            // The image is fetched from Supabase storage.
            Expanded(
              flex: 4,
              child: Column(
                children: [
                  Expanded(
                    child:
                        myGardenPlant.mainPhotoUrl != null &&
                                myGardenPlant.mainPhotoUrl!.isNotEmpty
                            ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                myGardenPlant.mainPhotoUrl!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                                errorBuilder:
                                    (_, __, ___) => Image.asset(
                                      'images/No_Image_Available.jpg',
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: double.infinity,
                                    ),
                              ),
                            )
                            : Center(
                              child: Image.asset(
                                'images/No_Image_Available.jpg',
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                              ),
                            ),
                  ),
                  const SizedBox(height: 12),
                  // Button to change the main image of the plant.
                  ElevatedButton.icon(
                    onPressed: _pickAndUploadMainImage,
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
                          Text(
                            myGardenPlant.plantType,
                            style: const TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'ID: ${myGardenPlant.id}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          const SizedBox(height: 25),
                          RichText(
                            // Planting Date
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
                                    myGardenPlant.plantingDate,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            // Position
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
                                        text:
                                            myGardenPlant.position ??
                                            'Not specified',
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // IconButton to change the position.
                              IconButton(
                                icon: const Icon(
                                  Icons.edit_location_alt,
                                  color: Colors.teal,
                                ),
                                tooltip: 'Edit Position',
                                onPressed: () => _editPositionDialog(),
                              ),
                            ],
                          ),
                          const SizedBox(height: 30),
                          // Notes
                          _buildSection(
                            title: 'Notes',
                            count: myGardenPlant.notes?.length ?? 0,
                            icon: Icons.note,
                            child: SizedBox(
                              height: 180,
                              child:
                                  (myGardenPlant.notes == null ||
                                          myGardenPlant.notes!.isEmpty)
                                      ? const Center(
                                        child: Text(
                                          "No notes yet.",
                                          style: TextStyle(
                                            fontStyle: FontStyle.italic,
                                            fontSize: 16,
                                          ),
                                        ),
                                      )
                                      : Scrollbar(
                                        controller: _notesScrollController,
                                        child: ListView.builder(
                                          controller: _notesScrollController,
                                          itemCount:
                                              myGardenPlant.notes?.length ?? 0,
                                          itemBuilder: (ctx, index) {
                                            final note =
                                                myGardenPlant.notes![index];
                                            return Card(
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 4,
                                                  ),
                                              child: ListTile(
                                                title: Text(note),
                                                // Bottons to edit or delete the note.
                                                trailing: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    IconButton(
                                                      icon: const Icon(
                                                        Icons.edit,
                                                      ),
                                                      onPressed:
                                                          () => _editNoteDialog(
                                                            index,
                                                          ),
                                                    ),
                                                    IconButton(
                                                      icon: const Icon(
                                                        Icons.delete,
                                                      ),
                                                      onPressed:
                                                          () =>
                                                              _confirmDeleteNote(
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
                              onPressed: () => _addNoteDialog(),
                              icon: const Icon(Icons.add),
                              label: const Text("Add Note"),
                            ),
                          ),
                          // Watering Records.
                          _buildSection(
                            title: 'Watering Records',
                            count: myGardenPlant.wateringRecords?.length ?? 0,
                            icon: Icons.water_drop,
                            child: SizedBox(
                              height: 180,
                              child:
                                  (myGardenPlant.wateringRecords == null ||
                                          myGardenPlant
                                              .wateringRecords!
                                              .isEmpty)
                                      ? const Center(
                                        child: Text(
                                          "No watering records yet.",
                                          style: TextStyle(
                                            fontStyle: FontStyle.italic,
                                            fontSize: 16,
                                          ),
                                        ),
                                      )
                                      : Scrollbar(
                                        controller: _wateringScrollController,
                                        child: ListView.builder(
                                          controller: _wateringScrollController,
                                          itemCount:
                                              myGardenPlant
                                                  .wateringRecords
                                                  ?.length ??
                                              0,
                                          itemBuilder: (ctx, index) {
                                            final record =
                                                myGardenPlant
                                                    .wateringRecords![index];
                                            return Card(
                                              margin:
                                                  const EdgeInsets.symmetric(
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
                                                subtitle:
                                                    record.amount != 0
                                                        ? Text(
                                                          'Water: ${record.amount} ml',
                                                        )
                                                        : const Text(
                                                          'Watered (amount not specified)',
                                                        ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                            ),
                            action: TextButton.icon(
                              onPressed: () => _addWateringRecordDialog(),
                              icon: const Icon(Icons.add),
                              label: const Text("Add Watering"),
                            ),
                          ),
                          // Evolution Photos.
                          _buildSection(
                            title: 'Evolution Photos',
                            count: myGardenPlant.photos?.length ?? 0,
                            icon: Icons.photo,
                            child: SizedBox(
                              height: 180,
                              child:
                                  (myGardenPlant.photos == null ||
                                          myGardenPlant.photos!.isEmpty)
                                      ? const Center(
                                        child: Text(
                                          'No evolution photos yet.',
                                          style: TextStyle(
                                            fontStyle: FontStyle.italic,
                                            fontSize: 16,
                                          ),
                                        ),
                                      )
                                      : ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        itemCount:
                                            myGardenPlant.photos?.length ?? 0,
                                        itemBuilder: (ctx, index) {
                                          final evolutionPhoto =
                                              myGardenPlant.photos![index];
                                          return Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6.0,
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Expanded(
                                                  child: InkWell(
                                                    onTap: () {
                                                      _showEvolutionPhotoDialog(
                                                        index,
                                                      );
                                                    },
                                                    child: Hero(
                                                      tag:
                                                          evolutionPhoto
                                                              .imageUrl,
                                                      child: Container(
                                                        decoration: BoxDecoration(
                                                          border: Border.all(
                                                            color: Colors.black,
                                                            width: 2.5,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                12,
                                                              ),
                                                        ),
                                                        child: ClipRRect(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                12,
                                                              ),
                                                          child: Image.network(
                                                            evolutionPhoto
                                                                .imageUrl,
                                                            width: 200,
                                                            height:
                                                                double.infinity,
                                                            fit: BoxFit.cover,
                                                            errorBuilder: (
                                                              imgCtx,
                                                              error,
                                                              stackTrace,
                                                            ) {
                                                              return Container(
                                                                width: 200,
                                                                height:
                                                                    double
                                                                        .infinity,
                                                                color:
                                                                    Colors
                                                                        .grey[300],
                                                                child: const Icon(
                                                                  Icons
                                                                      .broken_image,
                                                                  size: 40,
                                                                  color:
                                                                      Colors
                                                                          .grey,
                                                                ),
                                                              );
                                                            },
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  DateFormat.yMMMd().format(
                                                    evolutionPhoto.dateTaken,
                                                  ),
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey[700],
                                                    fontStyle: FontStyle.italic,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                            ),
                            // Button to add a new evolution photo.
                            action: TextButton.icon(
                              onPressed: () => _addEvolutionPhoto(),
                              icon: const Icon(Icons.add_a_photo),
                              label: const Text("Add Photo"),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Button to delete the plant.
                  ElevatedButton.icon(
                    onPressed: () => _confirmDeletePlant(),
                    icon: const Icon(Icons.delete, color: Colors.white),
                    label: const Text(
                      'Delete Plant',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[400],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  } // end build method().

  // Functions to handle the different sections of the page and the tap of bottons.

  // This function allows the user to change the main image of the plant.
  // It is an asynchronous function that uses FilePicker to pick an image
  // from the file system and then uploads it to Supabase storage.
  Future<void> _pickAndUploadMainImage() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final currentPlant = ref.read(selectedGardenPlantProvider(widget.plantId));
    // result contains the file picked by the user.
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    // Check if the widget is still mounted before proceeding.
    if (!mounted) return;

    // Check if the user selected a file.
    if (result != null && result.files.isNotEmpty) {
      // First file selected.
      final file = result.files.first;
      // Path of the file on the device.
      final imagePath = file.path;

      if (imagePath == null) {
        scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('Could not get image path.')),
        );
        return;
      }

      try {
        scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('Uploading main image...')),
        );
        // Get the bytes of the image file.
        final imageBytes = file.bytes ?? await File(imagePath).readAsBytes();
        if (!mounted) return;

        // Upload the image to Supabase storage. As a result, it returns
        // the URL of the uploaded image.
        final newMainPhotoUrl = await GardenPlant.uploadImage(
          imageBytes: imageBytes,
          imageType: "profile",
          plantId: currentPlant.id,
          fileName: "profile_${currentPlant.id}",
        );
        if (!mounted) return;

        // Check if the upload was successful.
        if (newMainPhotoUrl == null || newMainPhotoUrl.isEmpty) {
          scaffoldMessenger.showSnackBar(
            const SnackBar(content: Text('Error uploading main image.')),
          );
          return;
        }
        // Read again for security purpose (the plant may have been modified
        // in the meantime).
        final plantToUpdate = ref.read(
          selectedGardenPlantProvider(widget.plantId),
        );
        // Change the main photo URL of the plant.
        final updatedPlant = plantToUpdate.copyWith(
          mainPhotoUrl: newMainPhotoUrl,
        );
        // Update the plant in the provider.
        await ref.read(gardenPlantsProvider.notifier).updatePlant(updatedPlant);
        // Show a success message to the user.
        scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('Main image updated!')),
        );
      } catch (e) {
        if (!mounted) return;
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('Error processing main image: ${e.toString()}'),
          ),
        );
        debugPrint("Error in _pickAndUploadMainImage: $e");
      }
    }
  } // end _pickAndUploadMainImage method.

  // Function to add an evolution photo to the plant and update the storage online
  // accordingly. It also allows the user to add an optional note to the photo.
  Future<void> _addEvolutionPhoto() async {
    // Picking an image from the device using FilePicker.
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    // Control if the widget is still mounted before proceeding.
    if (!mounted || result == null || result.files.single.path == null) return;

    final imageFile = result.files.single;
    final imagePath = imageFile.path!;
    // Controller for the note input field.
    final noteController = TextEditingController();

    // Shows a dialog to confirm the addition of the photo and allow the user
    // to add a note.
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text(
              'Add Photo Note',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            content: TextField(
              controller: noteController,
              decoration: const InputDecoration(labelText: 'Optional note'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: const Text('Add Photo'),
              ),
            ],
          ),
    );
    // If the widget is not mounted or the user did not confirm the addition,
    // exit the method without doing anything.
    if (!mounted || confirmed != true) return;

    // Now, we proceed to upload the photo and update the plant.
    try {
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('Uploading photo...')),
      );
      // Get the bytes of the image file.
      final imageBytes = imageFile.bytes ?? await File(imagePath).readAsBytes();
      if (!mounted) return;

      final timestamp = DateTime.now();
      final formattedTimestamp = timestamp
          .toIso8601String()
          .replaceAll('.', '_')
          .replaceAll(':', '-');
      final safeFileName = "evolution_$formattedTimestamp";

      final currentPlant = ref.read(
        selectedGardenPlantProvider(widget.plantId),
      );
      // Upload the image to Supabase storage.
      final newImageUrl = await GardenPlant.uploadImage(
        imageBytes: imageBytes,
        imageType: "evolution",
        plantId: currentPlant.id,
        fileName: safeFileName,
      );
      // Check if the widget is still mounted after the async operation.
      if (!mounted) return;

      if (newImageUrl == null || newImageUrl.isEmpty) {
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text('Error uploading photo. Please try again.'),
          ),
        );
        return;
      }
      // Create a new PlantPhoto object with the uploaded image URL and the note.
      final newPhoto = PlantPhoto(
        imageUrl: newImageUrl,
        dateTaken: timestamp,
        note:
            noteController.text.trim().isNotEmpty
                ? noteController.text.trim()
                : null,
      );
      // Update the plant's photos list with the new photo.
      final List<PlantPhoto> updatedPhotos = [
        ...currentPlant.photos ?? [],
        newPhoto,
      ];
      // Create a new GardenPlant object with the updated photos.
      final GardenPlant updatedPlant = currentPlant.copyWith(
        photos: updatedPhotos,
      );
      // Update the plant in the provider.
      await ref.read(gardenPlantsProvider.notifier).updatePlant(updatedPlant);
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('Photo added successfully!')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: ${e.toString()}')),
      );
      debugPrint("Error during _addEvolutionPhoto process: $e");
    }
  } // end _addEvolutionPhoto method.

  // Function to show a dialog with the evolution photo in detail.
  Future<void> _showEvolutionPhotoDialog(int photoIndex) async {
    final myGardenPlant = ref.read(selectedGardenPlantProvider(widget.plantId));
    final evolutionPhoto = myGardenPlant.photos![photoIndex];

    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    // We show a dialog with the photo and options to delete it.
    final result = await showDialog<_PhotoActionDialogResult>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return Dialog(
          insetPadding: const EdgeInsets.all(10),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Hero(
                        tag: evolutionPhoto.imageUrl,
                        // This widget allows the user for zooming and panning.
                        child: InteractiveViewer(
                          panEnabled: true,
                          minScale: 0.5,
                          maxScale: 4.0,
                          child: Image.network(
                            evolutionPhoto.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (ctx, err, st) => const Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.broken_image,
                                        size: 100,
                                        color: Colors.red,
                                      ),
                                      SizedBox(height: 8),
                                      Text("Error loading image"),
                                    ],
                                  ),
                                ),
                          ),
                        ),
                      ),
                    ),
                    // Botton to close the dialog.
                    Positioned(
                      top: 0,
                      right: 0,
                      child: IconButton(
                        icon: const Icon(Icons.close),
                        onPressed:
                            () => Navigator.of(
                              dialogContext,
                            ).pop(_PhotoActionDialogResult.cancelled),
                      ),
                    ),
                  ],
                ),
                if (evolutionPhoto.note != null &&
                    evolutionPhoto.note!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    child: Text(
                      evolutionPhoto.note!,
                      style: const TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Taken on: ${DateFormat.yMMMd().format(evolutionPhoto.dateTaken)}',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextButton.icon(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    label: const Text(
                      'Delete Photo',
                      style: TextStyle(color: Colors.red),
                    ),
                    onPressed: () async {
                      // Asking for confirmation before deleting the photo.
                      final confirmDelete = await showDialog<bool>(
                        context:
                            dialogContext, 
                        builder:
                            (confirmCtx) => AlertDialog(
                              title: const Text(
                                'Delete Photo',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              content: const Text(
                                'Are you sure you want to delete this photo? This action cannot be undone.',
                              ),
                              actions: [
                                TextButton(
                                  onPressed:
                                      () => Navigator.of(confirmCtx).pop(false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed:
                                      () => Navigator.of(confirmCtx).pop(true),
                                  child: const Text(
                                    'Delete',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                      );
                      // The user confirmed the deletion of the evolution pic.
                      if (confirmDelete == true) {
                        try {
                          Uri uri = Uri.parse(evolutionPhoto.imageUrl);
                          String pathInBucket = uri.pathSegments
                              .sublist(
                                uri.pathSegments.indexOf('user-plants-images') +
                                    1,
                              )
                              .join('/');

                          bool deletedFromStorage =
                              await GardenPlant.deleteImageFromStorage(pathInBucket);
                          // The photo was deleted from storage and the provider 
                          // will be updated accordingly.
                          if (deletedFromStorage) {
                            final currentPlantData = ref.read(
                              selectedGardenPlantProvider(widget.plantId),
                            );
                            List<PlantPhoto> updatedPhotosList = List.from(
                              currentPlantData.photos ?? [],
                            );
                            if (photoIndex >= 0 &&
                                photoIndex < updatedPhotosList.length) {
                              updatedPhotosList.removeAt(photoIndex);
                            }
                            final updatedPlant = currentPlantData.copyWith(
                              photos: updatedPhotosList,
                            );
                            await ref
                                .read(gardenPlantsProvider.notifier)
                                .updatePlant(updatedPlant);

                            if (dialogContext.mounted) {
                              navigator.pop(_PhotoActionDialogResult.deleted);
                            }
                          } else {
                            if (dialogContext.mounted) {
                              navigator.pop(_PhotoActionDialogResult.error);
                            }
                          }
                        } catch (e) {
                          debugPrint("Error during photo deletion process: $e");
                          if (dialogContext.mounted) {
                            navigator.pop(_PhotoActionDialogResult.error);
                          }
                        }
                      }
                      // Se confirmDelete è false, non fare nulla, il dialogo della foto rimane aperto
                      // a meno che non si voglia chiuderlo con .cancelled. Per ora, lo lasciamo aperto.
                    },
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );

    // DOPO CHE showDialog (per la foto ingrandita) SI È COMPLETATO
    if (!mounted) {
      return; // Protegge l'uso di pageContext (per ScaffoldMessenger)
    }

    if (result == _PhotoActionDialogResult.deleted) {
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('Photo deleted successfully.')),
      );
    } else if (result == _PhotoActionDialogResult.error) {
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('Could not delete photo. Please try again.'),
        ),
      );
    }
    // Nessuna azione per .cancelled o null (se barrierDismissible chiude il dialogo)
  }

  // This function allows the user to edit a note of the plant.
  Future<void> _editNoteDialog(int index) async {
    final myGardenPlant = ref.read(selectedGardenPlantProvider(widget.plantId));
    final controller = TextEditingController(
      text: myGardenPlant.notes?[index] ?? '',
    );
    await showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text(
              'Edit Note',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            content: TextField(controller: controller),
            // If the user presses Cancel, the dialog will close without doing anything.
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Cancel'),
              ),
              // If the user presses Save, the note will be updated.
              TextButton(
                onPressed: () async {
                  final newNote = controller.text;

                  if (myGardenPlant.notes == null ||
                      index < 0 ||
                      index >= myGardenPlant.notes!.length) {
                    Navigator.of(dialogContext).pop(); 
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Note not found or changed.'),
                      ),
                    );
                    return;
                  }

                  final updatedNotes = [...myGardenPlant.notes!];
                  updatedNotes[index] = newNote;
                  final updated = myGardenPlant.copyWith(notes: updatedNotes);
                  await ref
                      .read(gardenPlantsProvider.notifier)
                      .updatePlant(updated);

                  if (!mounted) return; 
                  if (dialogContext.mounted) {
                    Navigator.of(dialogContext).pop();
                  }
                },
                child: const Text('Save'),
              ),
            ],
          ),
    );
    controller.dispose(); 
  } // end _editNoteDialog method.



  // Function to add a new note to the plant.
  Future<void> _addNoteDialog() async {

    final controller = TextEditingController();
    await showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text(
              'Add Note',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            content: TextField(controller: controller),
            // If the user presses Cancel, the dialog will close without doing anything.
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Cancel'),
              ),
              // If the user presses Add, a new note will be added.
              TextButton(
                onPressed: () async {
                  final navigator = Navigator.of(dialogContext);
                  final newNote = controller.text.trim();
                  if (newNote.isEmpty) {
                      navigator.pop();
                    return;
                  }
                  final currentPlant = ref.read(
                    selectedGardenPlantProvider(widget.plantId),
                  );
                  final List<String> updatedNotes = [
                    ...currentPlant.notes ?? [],
                    newNote,
                  ];
                  // Update the plant with the new note.
                  final updated = currentPlant.copyWith(notes: updatedNotes);
                  await ref
                      .read(gardenPlantsProvider.notifier)
                      .updatePlant(updated);
                  if (!mounted) return;
                  if (dialogContext.mounted) Navigator.of(dialogContext).pop();
                },
                child: const Text('Add'),
              ),
            ],
          ),
    );
    controller.dispose();
  } // end _addNoteDialog method.



  // Function to confirm the deletion of a note.
  Future<void> _confirmDeleteNote(int index) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context); 

    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text(
              'Delete Note',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            content: const Text('Are you sure you want to delete this note?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
    // If the user confirmed the deletion, we proceed to delete the note.
    if (confirmed == true) {
      final currentPlant = ref.read(
        selectedGardenPlantProvider(widget.plantId),
      );
      if (currentPlant.notes == null ||
          index < 0 ||
          index >= currentPlant.notes!.length) {
        scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('Note not found or already deleted.')),
        );
        return;
      }
      final updatedNotes = [...currentPlant.notes!..removeAt(index)];
      final updated = currentPlant.copyWith(notes: updatedNotes);
      await ref.read(gardenPlantsProvider.notifier).updatePlant(updated);
    }
  } // end _confirmDeleteNote method.



  // Function to edit the position of the plant in the garden.
  Future<void> _editPositionDialog() async {
    final myGardenPlant = ref.read(selectedGardenPlantProvider(widget.plantId));

    final controller = TextEditingController(
      text: myGardenPlant.position ?? '',
    );
    await showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text(
              'Edit Position',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            content: TextField(controller: controller),
            // If the user presses Cancel, the dialog will close without doing anything.
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Cancel'),
              ),
              // If the user presses Save, the position will be updated.
              TextButton(
                onPressed: () async {
                  final updated = myGardenPlant.copyWith(
                    position: controller.text.trim(),
                  );
                  await ref
                      .read(gardenPlantsProvider.notifier)
                      .updatePlant(updated);
                  if (!mounted) return;
                  if (dialogContext.mounted) Navigator.of(dialogContext).pop();
                },
                child: const Text('Save'),
              ),
            ],
          ),
    );
    controller.dispose(); 
  } // end _editPositionDialog method.

  Future<void> _confirmDeletePlant() async {
    final navigator = Navigator.of(context); // Cattura per pop della pagina

    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text(
              'Delete Plant',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            content: const Text('Are you sure you want to delete this plant?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );

    if (!mounted) return;
    if (confirmed == true) {
      // TODO: Implementare l'eliminazione di TUTTE le foto della pianta dallo storage
      // prima di eliminare la pianta dal DB.
      // Esempio concettuale:
      // if (plant.photos != null) {
      //   for (var photo in plant.photos!) {
      //     Uri uri = Uri.parse(photo.imageUrl);
      //     String pathInBucket = uri.pathSegments.sublist(uri.pathSegments.indexOf('user-plants-images') + 1).join('/');
      //     await GardenPlant.deleteImageFromStorage(pathInBucket);
      //   }
      // }
      // if (plant.mainPhotoUrl != null && plant.mainPhotoUrl!.isNotEmpty){
      //    Uri uri = Uri.parse(plant.mainPhotoUrl!);
      //    String pathInBucket = uri.pathSegments.sublist(uri.pathSegments.indexOf('user-plants-images') + 1).join('/');
      //    await GardenPlant.deleteImageFromStorage(pathInBucket);
      // }
      final myGardenPlant = ref.read(
        selectedGardenPlantProvider(widget.plantId),
      );

      await ref.read(gardenPlantsProvider.notifier).removePlant(myGardenPlant);
      if (!mounted) return;
      navigator.pop(); // Torna indietro dalla pagina della pianta
    }
  } // end _confirmDeletePlant method.


  // Function to add a watering record to the plant.
  Future<void> _addWateringRecordDialog() async {
    final controller = TextEditingController();

    await showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text(
              'Add Watering Record',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            content: TextField(
              controller: controller,
              decoration: const InputDecoration(labelText: 'Water amount (ml)'),
              keyboardType: TextInputType.number,
            ),
            actions: [
              // If the user presses Cancel, the dialog will close without doing anything.
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Cancel'),
              ),
              // if the user presses Add, a new watering record will be added.
              TextButton(
                onPressed: () async {
                  final double? quantity = double.tryParse(controller.text);
                  // Getting the current plant data from the provider.
                  final currentPlant = ref.read(
                    selectedGardenPlantProvider(widget.plantId),
                  );
                  final List<WateringRecord> updatedRecords = [
                    ...currentPlant.wateringRecords ?? [],
                    WateringRecord(date: DateTime.now(), amount: quantity ?? 0),
                  ];
                  final GardenPlant updatedPlantData = currentPlant.copyWith(
                    wateringRecords: updatedRecords,
                  );
                  // Updating the plant in the provider.
                  await ref
                      .read(gardenPlantsProvider.notifier)
                      .updatePlant(updatedPlantData);
                  if (dialogContext.mounted) Navigator.of(dialogContext).pop();
                },
                child: const Text('Add'),
              ),
            ],
          ),
    );
    controller.dispose();
  } // end _addWateringRecordDialog method.

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
            if (action != null)
              Align(alignment: Alignment.centerRight, child: action),
          ],
        ),
      ),
    );
  } // end _buildSection method.
} // end SpecificGardenPlantPage class.
