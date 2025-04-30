import 'package:flutter/material.dart';
import 'package:my_green_space/pages/home_garden_page.dart';
import 'package:my_green_space/pages/homepage.dart';
import 'package:my_green_space/pages/plant_catalog_page.dart';

// The MyDrawer widget defines the application's main navigation drawer.
// It is accessible from every page, providing a consistent way 
// for users to move between major sections of the app.
// When a user goes to another page, the previous page is completely replaced 
// using pushAndRemoveUntil, ensuring a clean navigation hierarchy without the stack mode.
// This approach keeps only one main page active at a time and avoids unnecessary 
// back navigation.

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint("Building MyDrawer...");

    return Drawer(
      child: ListView(
        // padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(child: Text("ciao")),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text("Home"),
            onTap: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) {
                    return const Homepage();
                  },
                ),
                (route) => false,
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.park),
            title: const Text("Catalog of plants"),
            onTap: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) {
                    return const PlantCatalogPage();
                  },
                ),
                (route) => false,
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.eco),
            title: const Text("My Home Garden"),
            onTap: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) {
                    return const HomeGardenPage();
                  },
                ),
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  } // end build.
} // end MyDrawer.
