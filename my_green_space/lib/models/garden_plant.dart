import 'dart:typed_data';
import 'package:flutter/material.dart'; 
import 'package:my_green_space/utilities/support_types.dart'; 
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

// This class represents a plant in the user's garden, and include parameters
// such as  the type, the planting date, the notes, the position, 
// the photos showing its evolution and watering records.
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
    this.notes,
    this.position,
    this.mainPhotoUrl,
    this.photos,
    this.wateringRecords,
  })  : id = id ?? const Uuid().v4(),
        plantingDate = plantingDate ?? DateTime.now();

  // Method to create a copy of the GardenPlant with optional modifications.
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
  } // end copyWith.

  // Factory constructor to create a GardenPlant from a JSON object.
  factory GardenPlant.fromJson(Map<String, dynamic> jsonItem) {
    return GardenPlant(
      id: jsonItem['id'] as String,
      plantType: jsonItem['plantType'] as String,
      plantingDate: DateTime.parse(jsonItem['plantingDate'] as String),
      notes: (jsonItem['notes'] as List<dynamic>?)?.map((e) => e as String).toList(),
      position: jsonItem['position'] as String?,
      mainPhotoUrl: jsonItem['mainPhotoUrl'] as String?,
      photos: (jsonItem['photos'] as List<dynamic>?)
          ?.map((e) {
            final map = e as Map<String, dynamic>;
            return PlantPhoto(
              imageUrl: map['imageUrl'] as String,
              dateTaken: DateTime.parse(map['dateTaken'] as String),
              note: map['note'] as String?,
            );
          }).toList(),
      wateringRecords: (jsonItem['wateringRecords'] as List<dynamic>?)
          ?.map((e) {
            final map = e as Map<String, dynamic>;
            return WateringRecord(
              date: DateTime.parse(map['date'] as String),
              amount: (map['amount'] as num).toDouble(),
            );
          }).toList(),
    );
  }

  // Method to convert the GardenPlant to a JSON object.
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
            'note': photo.note,
          }).toList(),
      'wateringRecords': wateringRecords?.map((record) => {
            'date': record.date.toIso8601String(),
            'amount': record.amount,
          }).toList(),
    };
  }

  // Method that uploads an image to Supabase storage. It returns
  // the public URL of the uploaded image.
  // The image can be either a profile picture or an evolution photo.
  static Future<String?> uploadImage({
    required Uint8List imageBytes,
    required String imageType, // "profile" or "evolution"
    required String plantId,
    required String fileNameWithExt, 
  }) async {
    try {
      final storage = Supabase.instance.client.storage;
      const bucketId = 'user-plants-images';
      late final String path;

      // Path in the storage bucket.
      path = 'plants/plant_$plantId/$imageType/$fileNameWithExt';

      if (imageType == 'profile') {
        // If the image is a profile picture, we need to delete any existing
        // profile images
        final String dirPath = 'plants/plant_$plantId/profile';
        try {
          final fileList = await storage.from(bucketId).list(path: dirPath);
          if (fileList.isNotEmpty) {
            // All files in the profile directory except the one being uploaded.
            final pathsToDelete = fileList
                .where((f) => f.name != fileNameWithExt) 
                .map((f) => '$dirPath/${f.name}')
                .toList();
            if (pathsToDelete.isNotEmpty) {
              debugPrint("Deleting old profile files: $pathsToDelete");
              await storage.from(bucketId).remove(pathsToDelete);
            }
          }
        } catch (e) {
          debugPrint("Error deleting old profile images in $dirPath: $e");
          // Non bloccare l'upload per questo, ma loggalo.
        }
      } 

      debugPrint("Uploading image to path: $path");
      // Upload the image to the specified path in the storage bucket.
      await storage.from(bucketId).uploadBinary(
            path,
            imageBytes,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
          );
      // Get the public URL of the uploaded image.
      final publicUrl = storage.from(bucketId).getPublicUrl(path);
      debugPrint("Image uploaded successfully: $publicUrl");
      return "$publicUrl?updated=${DateTime.now().millisecondsSinceEpoch}"; // Per cache busting
    } catch (e) {
      debugPrint("Exception during image upload ($imageType for $plantId): $e");
      return null;
    }
  } // end uploadImage.

  // Method to delete an image from Supabase storage.
  static Future<bool> deleteImageFromStorage(String pathInBucket) async {
    try {
      final storage = Supabase.instance.client.storage;
      const bucketId = 'user-plants-images';

      debugPrint("Attempting to delete image from storage at path: $pathInBucket");
      final List<FileObject> result = await storage.from(bucketId).remove([pathInBucket]);

      if (result.isNotEmpty) {
        debugPrint("Image deleted successfully from storage: ${result.first.name}");
        return true;
      } else {
        debugPrint("Image not found (or already deleted) at path: $pathInBucket. Considered successful for client.");
        return true; 
      }
    } catch (e) {
      debugPrint("Exception during image deletion from storage ($pathInBucket): $e");
      return false;
    }
  } // end deleteImageFromStorage.
} // end class GardenPlant.
