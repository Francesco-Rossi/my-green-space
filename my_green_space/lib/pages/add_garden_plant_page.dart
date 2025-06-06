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
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    imageExt = result?.files.single.extension ?? '';

    if (result != null && result.files.single.bytes != null) {
      setState(() {
        customImageBytes = result.files.single.bytes!;
      });
    }
  } // end pickImage method.

  // Method to add a note to the notes list.
  void addNote() {
    final text = notesController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        notesList.add(text);
        notesController.clear();
      });
    }
  } // end addNote method.

  @override
  Widget build(BuildContext context) {
    final plantType = ref.watch(selectedPlantProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final orientation = MediaQuery.of(context).orientation;
    final isPortrait = orientation == Orientation.portrait;
    final isSmallWideScreen = !isPortrait && screenWidth <= 850;

    final double paddingValue = isSmallWideScreen ? 12 : 24;
    final double fontSize = isSmallWideScreen ? 16 : 24;
    final buttonStyle = ElevatedButton.styleFrom(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallWideScreen ? 10 : 20,
        vertical: isSmallWideScreen ? 5 : 10,
      ),
      backgroundColor: Colors.green[700],
      textStyle: TextStyle(fontSize: isSmallWideScreen ? 12 : 16),
    );

    final imageWidget = ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child:
          customImageBytes != null
              ? Image.memory(customImageBytes!, fit: BoxFit.cover)
              : plantType.imageAsset != null && plantType.imageAsset!.isNotEmpty
              ? Image.asset(plantType.imageAsset!, fit: BoxFit.cover)
              : Image.asset("images/No_Image_Available.jpg", fit: BoxFit.cover),
    );

    final changeImageButton = ElevatedButton.icon(
      onPressed: pickImage,
      icon: const Icon(Icons.upload),
      label: Text(
        "Change Image",
        style: TextStyle(fontSize: isSmallWideScreen ? 14 : 16),
      ),
      style: buttonStyle,
    );

    final formSection = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Planting Date",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: fontSize),
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
            if (picked != null) setState(() => plantingDate = picked);
          },
          child: AbsorbPointer(
            child: TextFormField(
              decoration: InputDecoration(
                hintText: "${plantingDate.toLocal()}".split(' ')[0],
                prefixIcon: const Icon(Icons.calendar_today),
                border: const OutlineInputBorder(),
              ),
            ),
          ),
        ),
        const SizedBox(height: 18),
        Text(
          "Position",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: fontSize),
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
        Text(
          "Notes",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: fontSize),
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
              style: buttonStyle,
              child: Text(
                "Add",
                style: TextStyle(fontSize: isSmallWideScreen ? 14 : 16),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ...notesList.map(
          (note) => ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              note,
              style: TextStyle(fontSize: isSmallWideScreen ? 14 : 16),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => setState(() => notesList.remove(note)),
            ),
          ),
        ),
      ],
    );

    final addButton = Center(
      child: ElevatedButton.icon(
        onPressed: () async {
          final navigator = Navigator.of(context);
          final String? newUrl;
          Uint8List? imageToSave;
          String plantId = const Uuid().v4();

          // Setting the image to save.
          if (customImageBytes != null) {
            imageToSave = customImageBytes!;
          } else if (plantType.imageAsset != null &&
              plantType.imageAsset!.isNotEmpty) {
            imageToSave = await loadImageBytesFromAsset(plantType.imageAsset!);
          } else {
            imageToSave = await loadImageBytesFromAsset(
              "images/No_Image_Available.jpg",
            );
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
          ref.read(gardenPlantsProvider.notifier).addPlant(newGardenPlant);
          if (!mounted) return;
          navigator.pop(true);
          //Navigator.pop(context, true);
        },
        icon: const Icon(Icons.check),
        label: Text(
          "Add to Garden",
          style: TextStyle(fontSize: isSmallWideScreen ? 14 : 16),
        ),
        style: buttonStyle,
      ),
    );

    return Scaffold(
      appBar: AppBar(title: Text("Adding ${plantType.name} to my garden...")),
      body:
          isPortrait
              ? SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(paddingValue),
                  child: Column(
                    children: [
                      AspectRatio(aspectRatio: 16 / 9, child: imageWidget),
                      const SizedBox(height: 12),
                      changeImageButton,
                      const SizedBox(height: 24),
                      formSection,
                      const SizedBox(height: 24),
                      addButton,
                    ],
                  ),
                ),
              )
              : Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    flex: isSmallWideScreen ? 2 : 1,
                    child: Padding(
                      padding: EdgeInsets.all(paddingValue),
                      child: Column(
                        children: [
                          Expanded(child: imageWidget),
                          SizedBox(height: isSmallWideScreen ? 8 : 12),
                          changeImageButton,
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: isSmallWideScreen ? 3 : 1,
                    child: Padding(
                      padding: EdgeInsets.all(paddingValue),
                      child: Column(
                        children: [
                          Expanded(
                            child: SingleChildScrollView(child: formSection),
                          ),
                          const SizedBox(height: 12),
                          addButton,
                        ],
                      ),
                    ),
                  ),
                ],
              ),
    );
  }
} // end _AddGardenPlantPageState.
