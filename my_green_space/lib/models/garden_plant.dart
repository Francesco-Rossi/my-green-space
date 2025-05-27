import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:my_green_space/utilities/support_types.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

// This class represents a model for the plants in the user's garden.
// Each instance of this class can contain a profile image, 
// several user-taken images showing the plant's evolution, 
// and a list of watering records. 
// This information is stored in an online database called 'Supabase'.
class GardenPlant {
  final String id;
  final String plantType;
  final DateTime plantingDate;
  final List<String>? notes;
  final String? position;
  final String? mainPhotoUrl; 
  final List<PlantPhoto>? photos;
  final List<WateringRecord>? wateringRecords;

  // Constructor for the GardenPlant class. The only required field is `plantType`.
  // The `id` is generated automatically if not provided, and the `plantingDate` 
  // defaults to the current date. 
  // All other fields are optional and will be null if not specified.
  GardenPlant({
    String? id,
    required this.plantType,
    DateTime? plantingDate,
    this.notes,
    this.position,
    this.mainPhotoUrl,
    this.photos,
    this.wateringRecords,
  })  : id = id ?? const Uuid().v4(),
        plantingDate = plantingDate ?? DateTime.now();

  // Method to create a copy of the GardenPlant instance with updated fields.
  // The id, the plantType and the plantingDate remains unchanged,
  // while other fields can be updated.
  GardenPlant copyWith({
    List<String>? notes,
    String? position,
    String? mainPhotoUrl,
    List<PlantPhoto>? photos,
    List<WateringRecord>? wateringRecords,
  }) {
    return GardenPlant(
      id: id,  
      plantType: plantType,
      plantingDate: plantingDate,
      notes: notes ?? this.notes,
      position: position ?? this.position,
      mainPhotoUrl: mainPhotoUrl ?? this.mainPhotoUrl,
      photos: photos ?? this.photos,
      wateringRecords: wateringRecords ?? this.wateringRecords,
    );
  } // end copyWith method.

  // Factory constructor to convert a map (e.g. from Supabase or JSON)
  // into a GardenPlant instance.
  factory GardenPlant.fromJson(Map<String, dynamic> jsonItem) {
    return GardenPlant(
      id: jsonItem['id'] as String,
      plantType: jsonItem['plantType'] as String,
      plantingDate: DateTime.parse(jsonItem['plantingDate']),
      notes: List<String>.from(jsonItem['notes'] ?? []),
      position: jsonItem['position'] as String?,
      mainPhotoUrl: jsonItem['mainPhotoUrl'] as String?,
      photos: (jsonItem['plant_photos'] as List<dynamic>?)
          ?.map((e) => PlantPhoto(
                imageUrl: e['imagePath'],
                dateTaken: DateTime.parse(e['dateTaken']),
                note: e['notes'],
              ))
          .toList(),
      wateringRecords: (jsonItem['wateringRecords'] as List<dynamic>?)
          ?.map((e) => WateringRecord(
                date: DateTime.parse(e['date']),
                amount: (e['amount'] as num).toDouble(),
              ))
          .toList(),
    );
  } // end fromMap factory.

  // Method to convert a GardenPlant instance into a JSON object.
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
            'notes': photo.note,
          }).toList(),
      'wateringRecords': wateringRecords?.map((record) => {
            'date': record.date.toIso8601String(),
            'amount': record.amount,
          }).toList(),
    };
  } // end toJson method.

  // This static method uploads an image to the Supabase storage bucket and
  // returns the public URL of the uploaded image.
  // The image can be either a profile image or an evolution image.
  static Future<String?> uploadImage({
    required Uint8List imageBytes,
    required String imageType, // "profile" or "evolution"
    required String plantId,
    required fileName,
  }) async {
    try {
      final storage = Supabase.instance.client.storage;
      const bucketId = 'user-plants-images';
      late final String path;
      // Determine the path based on the image type.
      if (imageType == 'profile') {
        path = 'plants/plant_$plantId/profile/$fileName.jpg';
        // If the image type is 'profile', we first delete any existing profile images.  
        final fileList = await storage.from(bucketId).list(path: 'plants/plant_$plantId/profile');
        final pathsToDelete = fileList.map((f) => 'plants/plant_$plantId/${f.name}').toList();

        if (pathsToDelete.isNotEmpty) {
          debugPrint("Deleting old profile files: $pathsToDelete");
          await storage.from(bucketId).remove(pathsToDelete);
      }
      } else if (imageType == 'evolution') {
        path = 'plants/$plantId/evolution/$fileName.jpg';
      } else {
        throw Exception('Image type not supported!: $imageType');
      }
      debugPrint("Uploading image to path: $path");
      // Upload the image to the specified path in the storage bucket.
      await storage
          .from(bucketId)
          .uploadBinary(path, imageBytes, fileOptions: const FileOptions(cacheControl: '3600', upsert: true));

      final publicUrl = storage.from(bucketId).getPublicUrl(path);
      debugPrint("Image uploaded successfully: $publicUrl");
      return "$publicUrl?updated=${DateTime.now().millisecondsSinceEpoch}";
    } catch (e) {
      debugPrint("Exception during image upload: $e");
      return null;
    } // end try-catch block.
  } // end uploadImage method.
} // end GardenPlant class.
