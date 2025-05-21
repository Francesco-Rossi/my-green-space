// This file defines support types used throughout the app.

// Enumeration of months.
enum Month {
  january, february, march, april, may, june,
  july, august, september, october, november, december
} // end Month enum.

// Istances of this class represent a time interval between two months.
class Period {
  final Month start;
  final Month end;

  Period({required this.start, required this.end});

  // Factory constructor that returns a Period object from a JSON map.
  factory Period.fromJson(Map<String, dynamic> json) {
    return Period(
      start: Month.values.firstWhere((m) => m.name == json['start']),
      end: Month.values.firstWhere((m) => m.name == json['end']),
    );
  } // end factory constructor.

  @override
  String toString() {
    return '${start.name[0].toUpperCase() + start.name.substring(1)} - ${end.name[0].toUpperCase() + end.name.substring(1)}';
  }
} // end Period class.

// The istances of this class define a temperature range with minimum and maximum values.
class TemperatureRange {
  final int min;
  final int max;

  const TemperatureRange({required this.min, required this.max});

  // Factory constructor that returns a TemperatureRange object from a JSON map.
  factory TemperatureRange.fromJson(Map<String, dynamic> json) {
    return TemperatureRange(
      min: json['min'],
      max: json['max'],
    );
  } // end factory constructor.

  @override
  String toString() {
    return '$min°C - $max°C';
  }
} // end TemperatureRange class.

// Represents a photo taken of a plant, including its file path, 
// the date it was taken, and optional notes.
class PlantPhoto {
  final String imagePath; 
  final DateTime dateTaken;
  final String? notes;

  PlantPhoto({
    required this.imagePath,
    required this.dateTaken,
    this.notes,
  });
} // end PlantPhoto class.

// This class represents a single watering event with date and amount of water used.
class WateringRecord {
  final DateTime date;
  final double amount; 
  
  WateringRecord({
    required this.date,
    required this.amount,
  });
} // end WateringRecord class.
