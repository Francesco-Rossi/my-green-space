import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_green_space/models/garden_plant.dart';   
import 'package:my_green_space/utilities/providers.dart';

class AddGardenPlantPage extends ConsumerStatefulWidget {
  
  const AddGardenPlantPage({super.key});

  @override
  ConsumerState<AddGardenPlantPage> createState() => _AddGardenPlantPageState();
}

class _AddGardenPlantPageState extends ConsumerState<AddGardenPlantPage> {
  late DateTime plantingDate;
  late TextEditingController notesController;
  late TextEditingController positionController;

  @override
  void initState() {
    super.initState(); 

    plantingDate = DateTime.now();
    notesController = TextEditingController();
    positionController = TextEditingController();
  }

  @override
  void dispose() {
    notesController.dispose();
    positionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final plantType = ref.watch(selectedPlantProvider);

    return Scaffold(
      appBar: AppBar(title: Text('Adding ${plantType.name} to my garden...')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text('Planting Date:', style: TextStyle(fontWeight: FontWeight.bold)),
            TextButton(
              child: Text('${plantingDate.toLocal()}'.split(' ')[0]),
              onPressed: () async {
                DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: plantingDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                );
                if (picked != null && picked != plantingDate) {
                  setState(() {
                    plantingDate = picked;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: notesController,
              decoration: const InputDecoration(
                labelText: 'Notes',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: positionController,
              decoration: const InputDecoration(
                labelText: 'Position',
                border: OutlineInputBorder(),
              ),
            ),
            const Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Crea GardenPlant con dati inseriti
                  final newGardenPlant = GardenPlant(
                    plantType: plantType,
                    plantingDate: plantingDate,
                    notes: [notesController.text.trim()].where((s) => s.isNotEmpty).toList(),
                    position: positionController.text.trim().isEmpty ? null : positionController.text.trim(),
                  );

                  // Aggiungi al provider
                  ref.read(gardenPlantsProvider.notifier).addPlant(newGardenPlant);

                  // Torna indietro
                  Navigator.pop(context);
                },
                child: const Text('Add to my garden'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
