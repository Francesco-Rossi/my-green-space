// This file defines support types used throughout the app.
// 
// - Month: Enumeration of months.
// - Period: Represents a time interval between two months.
// - TemperatureRange: Defines a temperature range with minimum and maximum values.

enum Month {
  january, february, march, april, may, june,
  july, august, september, october, november, december
} // end Month enum.

class Period {
  final Month start;
  final Month end;

  Period({required this.start, required this.end});

  @override
  String toString() {
    return '${start.name} - ${end.name}';
  }
} // end Period class.

class TemperatureRange {
  final int min;
  final int max;

  const TemperatureRange({required this.min, required this.max});

  @override
  String toString() {
    return '$min°C - $max°C';
  }
} // end TemperatureRange class.