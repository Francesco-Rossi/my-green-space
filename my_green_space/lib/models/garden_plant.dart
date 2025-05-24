import 'package:my_green_space/utilities/support_types.dart';
import 'package:uuid/uuid.dart';

class GardenPlant {
  final String id;
  final String plantType;
  final DateTime plantingDate;
  final List<String>? notes;
  final String? position;
  final String? mainPhotoUrl; 
  final List<PlantPhoto>? photos;
  final List<WateringRecord>? wateringRecords;

  GardenPlant({
    String? id,
    required this.plantType,
    DateTime? plantingDate,
    List<String>? notes,
    this.position,
    this.mainPhotoUrl,
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
      mainPhotoUrl: newMainPhotoPath ?? mainPhotoUrl,
      photos: newPhotos ?? photos,
      wateringRecords: newWateringRecords ?? wateringRecords,
    );
  } // end copyWith method.

  // Factory constructor to convert a Map (e.g. from Supabase or JSON)
  // into a GardenPlant instance.
  factory GardenPlant.fromJson(Map<String, dynamic> map) {
    return GardenPlant(
      id: map['id'] as String,
      plantType: map['plantType'] as String,
      plantingDate: DateTime.parse(map['plantingDate']),
      notes: List<String>.from(map['notes'] ?? []),
      position: map['position'] as String?,
      mainPhotoUrl: map['mainPhotoUrl'] as String?,
      photos: (map['plant_photos'] as List<dynamic>?)
          ?.map((e) => PlantPhoto(
                imageUrl: e['imagePath'],
                dateTaken: DateTime.parse(e['dateTaken']),
                notes: e['notes'],
              ))
          .toList(),
      wateringRecords: (map['wateringRecords'] as List<dynamic>?)
          ?.map((e) => WateringRecord(
                date: DateTime.parse(e['date']),
                amount: (e['amount'] as num).toDouble(),
              ))
          .toList(),
    );
  } // end fromMap factory.

  // Method to convert the GardenPlant instance into JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'plantType': plantType, 
      'plantingDate': plantingDate.toIso8601String(),
      'notes': notes,
      'position': position,
      'mainPhotoUrl': mainPhotoUrl,
      'photos': photos?.map((photo) => {
            'imageUrl': photo.imageUrl,
            'dateTaken': photo.dateTaken.toIso8601String(),
            'notes': photo.notes,
          }).toList(),
      'wateringRecords': wateringRecords?.map((record) => {
            'date': record.date.toIso8601String(),
            'amount': record.amount,
          }).toList(),
    };
  } // end toJson method.
} // end GardenPlant class.
