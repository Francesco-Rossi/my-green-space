import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_green_space/models/garden_plant.dart';
import 'package:my_green_space/utilities/providers.dart';
import 'package:my_green_space/utilities/support_types.dart';
import 'package:uuid/uuid.dart';

// This page allows the user to add a new plant to its garden,
// by compiling a form with the plant's details.
// The user can also choose an image for the plant from the file system,
// otherwise the default image for the plant type will be used.

// A ConsumerStatefulWidget is used because we need both mutable
// state (like form inputs and image selection) and access to
// Riverpod providers.
class AddGardenPlantPage extends ConsumerStatefulWidget {
  const AddGardenPlantPage({super.key});

  @override
  ConsumerState<AddGardenPlantPage> createState() => _AddGardenPlantPageState();
} // end AddGardenPlantPage class.

class _AddGardenPlantPageState extends ConsumerState<AddGardenPlantPage> {
  // State variables for the form inputs.
  late DateTime plantingDate;
  late TextEditingController notesController;
  late TextEditingController positionController;
  // List to hold notes added by the user.
  final List<String> notesList = [];
  // Extension for the image file, used when uploading the image.
  late String imageExt; 
  // Variable to hold the custom image (that is a list of bytes)
  // if the user selects an image.
  Uint8List? customImageBytes;

  // Initialize the state variables when the page is created.
  @override
  void initState() {
    super.initState();
    plantingDate = DateTime.now();
    notesController = TextEditingController();
    positionController = TextEditingController();
    imageExt = 'jpg';
  }

  // Dispose of the controllers when the page is disposed to free up resources.
  @override
  void dispose() {
    notesController.dispose();
    positionController.dispose();
    super.dispose();
  }

  // Asynchronous method to pick an image from the file system.
  Future<void> pickImage() async {
    // Use the file picker to select an image file. 
    // The result contains the selected file's data.
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    imageExt = result?.files.single.extension ?? ''; 

    // If the user selected a file and it has bytes, update the state.
    // The method setState triggers the rebuild of the widget.
    if (result != null && result.files.single.bytes != null) {
      setState(() {
        customImageBytes = result.files.single.bytes!;
      });
    }
  } // end pickImage method.

  // Method to add a note to the notes list.
  void addNote() {
    final text = notesController.text.trim();
    // Only add the note if the text is not empty.
    if (text.isNotEmpty) {
      setState(() {
        notesList.add(text);
        notesController.clear();
      });
    }
  } // end addNote method.

  @override
  Widget build(BuildContext context) {
    debugPrint("Building AddGardenPlantPage...");
    final plantType = ref.watch(selectedPlantProvider);

    return Scaffold(
      appBar: AppBar(title: Text("Adding ${plantType.name} to my garden...")),
      // The layout is a Row with two main sections:
      // the left side for the image and the right side for the form.
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Left side for the plant image and the button to change it.
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      // Display the custom image if available,
                      // otherwise display the default image for the plant type.
                      child:
                          customImageBytes != null
                              ? Image.memory(
                                customImageBytes!,
                                fit: BoxFit.cover,
                              )
                              : plantType.imageAsset != null &&
                                  plantType.imageAsset!.isNotEmpty
                              ?  
                                Image.asset(
                                plantType.imageAsset!,
                                fit: BoxFit.cover,
                              )
                              : Image.asset(
                                "images/No_Image_Available.jpg",
                                fit: BoxFit.cover,
                              ),
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
          ),
          // Right side for the form inputs.
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 40, right: 40, top: 50),
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Planting Date",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                            ),
                          ),
                          const SizedBox(height: 12),
                          GestureDetector(
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: plantingDate,
                                firstDate: DateTime(2000),
                                lastDate: DateTime.now(),
                              );
                              if (picked != null) {
                                setState(() => plantingDate = picked);
                              }
                            },
                            child: AbsorbPointer(
                              child: TextFormField(
                                decoration: InputDecoration(
                                  // Display the selected date in a user-friendly format.
                                  hintText:
                                      "${plantingDate.toLocal()}".split(' ')[0],
                                  prefixIcon: const Icon(Icons.calendar_today),
                                  border: const OutlineInputBorder(),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 18),

                          const Text(
                            "Position",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: positionController,
                            decoration: const InputDecoration(
                              hintText: "Add a position",
                              border: OutlineInputBorder(),
                            ),
                          ),

                          const SizedBox(height: 18),

                          const Text(
                            "Notes",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: notesController,
                                  decoration: const InputDecoration(
                                    hintText: "Add a note",
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: addNote,
                                child: const Text("Add"),
                              ),
                            ],
                          ),
                          // Display the list of notes added by the user.
                          // The user can also delete the notes he has added.
                          const SizedBox(height: 10),
                          ...notesList.map(
                            (note) => ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(note),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  setState(() {
                                    notesList.remove(note);
                                  });
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                  Center(
                    child: ElevatedButton.icon(
                      // When the user clicks this button, a new GardenPlant
                      // instance is created, and the respective provider is updated.
                      onPressed: () async {
                        final navigator = Navigator.of(context);
                        final String? newUrl;
                        Uint8List? imageToSave;
                        String plantId = const Uuid().v4();
                

                        // Setting the image to save.
                        if (customImageBytes != null) {
                          imageToSave = customImageBytes!;
                        } else if (plantType.imageAsset != null && plantType.imageAsset!.isNotEmpty) {
                          imageToSave = await loadImageBytesFromAsset(plantType.imageAsset!);
                        } else {
                          imageToSave = await loadImageBytesFromAsset("images/No_Image_Available.jpg");
                        } 
                        if (imageExt == '') {
                          imageExt = 'jpg'; // Default to jpg if no extension is provided.
                        }
                        // Upload the image to the storage and get the URL.
                        newUrl = await GardenPlant.uploadImage(
                          imageBytes: imageToSave,
                          imageType: 'profile',
                          plantId: plantId,
                          fileNameWithExt: "${plantType.name}_$plantId.$imageExt",
                        );
                        // Create a new GardenPlant instance with the form data.
                        final newGardenPlant = GardenPlant(
                          id: plantId,
                          plantType: plantType.name,
                          plantingDate: plantingDate,
                          mainPhotoUrl: newUrl ?? '',
                          notes: notesList,
                          position:
                              positionController.text.trim().isNotEmpty
                                  ? positionController.text.trim()
                                  : null,
                        );
                        // Updating the gardenPlantsProvider.
                        ref
                            .read(gardenPlantsProvider.notifier)
                            .addPlant(newGardenPlant);
                        if (!mounted) return;
                        navigator.pop(true);
                        //Navigator.pop(context, true);
                      },
                      icon: const Icon(Icons.check),
                      label: const Text("Add to Garden"),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 16,
                        ),
                        backgroundColor: Colors.green[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  } // end build method.
} // end _AddGardenPlantPageState.
