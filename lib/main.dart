// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';

// Screens & Utilities
import 'homepage.dart';
import 'hive_adapters.dart';
import 'colortheme.dart'; // Imports your custom AppTheme
import 'providers/shadow_provider.dart'; // Resolves the 'themeModeProvider' error

void main() async {
  // Try/catch block with the unused 'stacktrace' removed
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

    // Open the box
    await Hive.openBox('shadow_box');

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

// Upgraded to a ConsumerWidget to listen to Riverpod states
class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the theme state to enable the global toggle switch
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'Shadow Lab',
      // Apply your specific design system from colortheme.dart
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      home: const HomePage(),
    );
  }
}
