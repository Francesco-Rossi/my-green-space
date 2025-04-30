import 'package:flutter/material.dart';
import 'package:my_green_space/widgets/my_drawer.dart';

class Homepage extends StatelessWidget {
  const Homepage({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint("Building Homepage...");
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('My green space'),
      ),
      drawer: const MyDrawer(),
      body: const Center(
        child: Text("This is my homepage"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          debugPrint("Botton pressed!");
        },
        child: const Icon(Icons.add),
      ),
    );
  } // end build.
} // end Homepage.

