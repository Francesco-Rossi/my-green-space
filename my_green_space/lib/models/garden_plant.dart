import 'dart:typed_data';
import 'package:flutter/material.dart'; // Per debugPrint
import 'package:my_green_space/utilities/support_types.dart'; // Assicurati che il percorso sia corretto
import 'package:supabase_flutter/supabase_flutter.dart';
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
    this.notes,
    this.position,
    this.mainPhotoUrl,
    this.photos,
    this.wateringRecords,
  })  : id = id ?? const Uuid().v4(),
        plantingDate = plantingDate ?? DateTime.now();

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
  }

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

  static Future<String?> uploadImage({
    required Uint8List imageBytes,
    required String imageType, // "profile" or "evolution"
    required String plantId,
    required String fileName, // Nome base senza estensione
  }) async {
    try {
      final storage = Supabase.instance.client.storage;
      const bucketId = 'user-plants-images';
      late final String path;
      final String fullFileNameWithExt = '$fileName.jpg'; // Aggiungi estensione

      // Struttura path coerente: plants/<plantId>/<imageType>/<fileName>
      path = 'plants/$plantId/$imageType/$fullFileNameWithExt';

      if (imageType == 'profile') {
        // Se è una foto profilo, elimina le vecchie foto profilo per questa pianta
        final String dirPath = 'plants/$plantId/profile';
        try {
          final fileList = await storage.from(bucketId).list(path: dirPath);
          if (fileList.isNotEmpty) {
            // Non eliminare il file che stiamo per caricare se ha lo stesso nome (improbabile con timestamp)
            final pathsToDelete = fileList
                .where((f) => f.name != fullFileNameWithExt) // Evita di auto-eliminare se il nome è identico (raro)
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
      await storage.from(bucketId).uploadBinary(
            path,
            imageBytes,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
          );

      final publicUrl = storage.from(bucketId).getPublicUrl(path);
      debugPrint("Image uploaded successfully: $publicUrl");
      return "$publicUrl?updated=${DateTime.now().millisecondsSinceEpoch}"; // Per cache busting
    } catch (e) {
      debugPrint("Exception during image upload ($imageType for $plantId): $e");
      return null;
    }
  }

  static Future<bool> deleteImageFromStorage(String pathInBucket) async {
    try {
      final storage = Supabase.instance.client.storage;
      const bucketId = 'user-plants-images';

      debugPrint("Attempting to delete image from storage at path: $pathInBucket");
      final List<FileObject> result = await storage.from(bucketId).remove([pathInBucket]);

      // remove() restituisce una lista degli oggetti eliminati.
      // Se il file non esiste, la lista è vuota e non c'è errore.
      if (result.isNotEmpty) {
        debugPrint("Image deleted successfully from storage: ${result.first.name}");
        return true;
      } else {
        debugPrint("Image not found (or already deleted) at path: $pathInBucket. Considered successful for client.");
        return true; // Se non c'è, per il client è come se fosse stato eliminato.
      }
    } catch (e) {
      debugPrint("Exception during image deletion from storage ($pathInBucket): $e");
      return false;
    }
  } // end deleteImageFromStorage.
} // end class GardenPlant.
