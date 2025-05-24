import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_green_space/utilities/my_theme.dart';
import 'package:my_green_space/pages/homepage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://fvpaznhydblbqvtlccfn.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZ2cGF6bmh5ZGJsYnF2dGxjY2ZuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDgwMTQxNDEsImV4cCI6MjA2MzU5MDE0MX0.akLgcJyQoZcg0PowCR8FkLvLwYnAIAgtVovdfvyQDZA',
  );
  debugPrint('Supabase initialized!');

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


