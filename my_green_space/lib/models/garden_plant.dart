import 'package:my_green_space/models/plant.dart';
import 'package:my_green_space/utilities/support_types.dart';
import 'package:uuid/uuid.dart';

class GardenPlant {
  final String id;
  final Plant plantType;
  final DateTime plantingDate;
  final List<String>? notes;
  final String? position;
  final String? mainPhotoPath; 
  final List<PlantPhoto>? photos;
  final List<WateringRecord>? wateringRecords;

  GardenPlant({
    String? id,
    required this.plantType,
    DateTime? plantingDate,
    List<String>? notes,
    this.position,
    this.mainPhotoPath,
    List<PlantPhoto>? photos,
    List<WateringRecord>? wateringRecords,
  })  : id = id ?? const Uuid().v4(),
        plantingDate = plantingDate ?? DateTime.now(),
        photos = photos ?? [],
        notes = notes ?? [],
        wateringRecords = wateringRecords ?? [];

  GardenPlant copyWith({
    List<String>? newNotes,
    String? newPosition,
    String? newMainPhotoPath,
    List<PlantPhoto>? newPhotos,
    List<WateringRecord>? newWateringRecords,
  }) {
    return GardenPlant(
      id: id,  // l'id resta invariato
      plantType: plantType,
      plantingDate: plantingDate,
      notes: newNotes ?? notes,
      position: newPosition ?? position,
      mainPhotoPath: newMainPhotoPath ?? mainPhotoPath,
      photos: newPhotos ?? photos,
      wateringRecords: newWateringRecords ?? wateringRecords,
    );
  } // end copyWith method.
} // end GardenPlant class.
