import 'package:flutter/material.dart';
import 'package:my_green_space/widgets/my_drawer.dart';

class HomeGardenPage extends StatelessWidget {
  const HomeGardenPage({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint("Building HomeGardenPage...");

    return Scaffold(
      appBar: AppBar(
        title: const Text("Home Garden"),
      ),
      drawer: const MyDrawer(),
      body: const Text("This is the Home garden page"),
    );
  } // end build.
} // end HomeGardenPage.