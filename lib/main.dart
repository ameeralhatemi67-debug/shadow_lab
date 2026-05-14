// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:shadow_app/models/labs.dart';

// Screens & Utilities
import 'homepage.dart';
import 'hive_adapters.dart';
import 'colortheme.dart';
import 'providers/shadow_provider.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    // Initialize Hive
    await Hive.initFlutter();

    // Safe adapter registration (Prevents double-registration crashes)
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(ShadowSettingsAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(ShadowPairAdapter());
    }
    // --- NEW: Register the Lab Adapter (TypeID 2) ---
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(LabAdapter());
    }

    // Open the databases
    await Hive.openBox(
      'shadow_box',
    ); // Keep old box open temporarily to prevent errors
    // --- NEW: Open the dedicated workspace database ---
    await Hive.openBox<Lab>('labs_box');

    // Launch the app
    runApp(const ProviderScope(child: MyApp()));
  } catch (e) {
    debugPrint('Init Error: $e');
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Center(
              child: Text(
                'Startup Error:\n\n$e',
                style: const TextStyle(color: Colors.red, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the theme state to enable the global toggle switch
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'Shadow Lab',
      debugShowCheckedModeBanner: false, // Clean up the top right corner
      themeMode: themeMode,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      home: const HomePage(),
    );
  }
}
