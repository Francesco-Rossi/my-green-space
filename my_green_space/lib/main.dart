import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_green_space/my_theme.dart';
import 'package:my_green_space/pages/homepage.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Green Space',
      theme: myTheme,
      home: const Homepage(),
    );
  } // end build.
} // end MyApp.


