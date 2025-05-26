import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:my_green_space/utilities/support_types.dart';

// This model represents a plant in the catalog of the application.
// It includes various properties such as name, description, exposure, 
// and a list of tags describing the plant.
// Information of the plants are taken from 'https://www.ortomio.it/piante-da-orto'.
class Plant {
  final String name;          
  final String? description;   
  final String? imageAsset;    
  final List<String> tags;   
  final String? exposure;
  final TemperatureRange? temperatureRange; 
  final Period? transplantPeriod;
  final Period? harvestPeriod; 
  final String? irrigation;

  // Only the name of the plant and the list of tags are mandatory.
  // The list of tags is initialized to an empty list if not provided.
  // The other fields are optional and are set to null if not provided.
  Plant({
    required this.name,
    this.description,
    this.imageAsset,
    List<String>? tags,
    this.exposure,
    this.temperatureRange,
    this.transplantPeriod,
    this.harvestPeriod,
    this.irrigation,
  }) : tags = tags ?? []; 

  // Factory constructor to build a Plant object from a JSON map.
  factory Plant.fromJson(Map<String, dynamic> json) {
    return Plant(
      name: json['name'],
      description: json['description'],
      imageAsset: json['imageAsset'],
      tags: List<String>.from(json['tags'] ?? []),
      exposure: json['exposure'],
      temperatureRange: json['temperatureRange'] != null
          ? TemperatureRange.fromJson(json['temperatureRange'])
          : null,
      transplantPeriod: json['transplantPeriod'] != null
          ? Period.fromJson(json['transplantPeriod'])
          : null,
      harvestPeriod: json['harvestPeriod'] != null
          ? Period.fromJson(json['harvestPeriod'])
          : null,
      irrigation: json['irrigation'],
    );
  } // end factory constructor.

  // This static method loads the plant catalog from a local JSON file.
  // Parses each JSON object into a Plant instance using the 'fromJson' constructor.
  // Returns a Future that resolves to a list of Plant objects.
  static Future<List<Plant>> getPlantsCatalog() async {
    final jsonString = await rootBundle.loadString('assets/plants.json');
    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((jsonItem) => Plant.fromJson(jsonItem)).toList();
  } // end getPlantsCatalog() method.
} // end Plant class.