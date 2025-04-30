// This model represents a plant in the catalog of the application.
import 'package:my_green_space/support_types.dart';

class Plant {

  final String name;          
  final String? description;   
  final String? imageAsset;    
  final List<String> tags;    // Some descriptive tags for the plant.
  final String? exposure;
  final TemperatureRange? temperatureRange; 
  final Period? transplantPeriod;
  final Period? harvestPeriod; 
  final String? irrigation;

  // Only the name of the plant is mandatory. The other fields are optional 
  // and are set to null if not provided.
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

  // Static method that builds the list of plants for the catalog.
  // Informations are taken from 'https://www.ortomio.it/piante-da-orto'.
  static List<Plant> getPlantsCatalog() {
    return [
      Plant(
        name: "Garlic",
        description: "Garlic is a member of the lily family, like onions, leeks, and shallots. It is indispensable in the kitchen and important for health, which is why it should always have a place in the garden. Just a few square meters are enough to grow a year's supply. Thanks to its properties, it can also be used (alone or combined with other products) as a natural repellent against many troublesome garden pests.",
        imageAsset: "../images/plants/garlic.jpg",
        tags: ["bulb", "vegetable", "full sun", "low water need", "spring planting", "easy to grow"],
        exposure: "Full sun",
        temperatureRange: const TemperatureRange(min: 15, max: 25),
        transplantPeriod: Period(start: Month.november, end: Month.march),
        harvestPeriod: Period(start: Month.may, end: Month.june),
        irrigation: "Water only during dry periods, especially during bulb growth. Avoid overwatering.",
      ),
      Plant(
        name: "Agretti",
        description: "The Agretto (Salsola soda) is known by many names: Roscano, Frati’s beard or Negus beard, and also Lischi or Lischeri. It belongs to the Chenopodiaceae family, like spinach and Swiss chard. It is a typical Mediterranean specialty, very adaptable, and among the most tolerant to salinity and drought. Agretto is still relatively unknown in the kitchen, where it can actually be enjoyed in many ways: it is ideal boiled or quickly sautéed, but can also be eaten raw in mixed salads by those who appreciate its slightly tangy flavor.",
        imageAsset: "../images/plants/agretti.jpg",
        tags: ["spring planting", "full sun", "mediterranean", "easy to grow"],
        exposure: "Full sun",
        temperatureRange: const TemperatureRange(min: 16, max: 25),
        transplantPeriod: Period(start: Month.february, end: Month.june),
        harvestPeriod: Period(start: Month.january, end: Month.december),
        irrigation: "Water moderately after transplant until established, then irrigate rarely. Avoid waterlogging. Keep soil slightly moist before harvest to maintain tender leaves and stems.",
      ),
      /*Plant(
        name: "",
        description: "",
        imageAsset: "images/plants/....jpg",
        tags: ["", ""],
        exposure: "",
        temperatureRange: const TemperatureRange(min: , max: ),
        transplantPeriod: Period(start: , end: ),
        harvestPeriod: Period(start: , end: ),
        irrigation: "",
      ),
      Plant(
        name: "",
        description: "",
        imageAsset: "images/plants/....jpg",
        tags: ["", ""],
        exposure: "",
        temperatureRange: const TemperatureRange(min: , max: ),
        transplantPeriod: Period(start: , end: ),
        harvestPeriod: Period(start: , end: ),
        irrigation: "",
      ),*/
      // TODO.
    ];
  } // end getPlantsCatalog() method.
} // end Plant class.