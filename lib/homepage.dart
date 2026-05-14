// lib/homepage.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_inset_shadow/flutter_inset_shadow.dart'
    as inset; // Added for the Diamond inner shadow
import 'providers/shadow_provider.dart';
import 'widgets/shadow_card.dart';
import 'widgets/custom_panel.dart';
import 'utils/export_templates.dart';
import 'colortheme.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  String? selectedShadowId;
  // --- NEW: Controls the animation state ---
  bool isPanelOpen = false;

  @override
  Widget build(BuildContext context) {
    final shadows = ref.watch(shadowProvider);
    final currentTheme = ref.watch(themeModeProvider);
    final colors = Theme.of(context).extension<CustomColors>()!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final selectedPair = shadows
        .where((p) => p.id == selectedShadowId)
        .firstOrNull;

    return Scaffold(
      backgroundColor: colors.bgc,
      appBar: AppBar(
        backgroundColor: colors.bgc,
        title: const Text('Shadow Lab'),
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              currentTheme == ThemeMode.light
                  ? Icons.dark_mode
                  : Icons.light_mode,
            ),
            tooltip: 'Toggle Theme',
            onPressed: () {
              ref.read(themeModeProvider.notifier).toggleTheme();
            },
          ),
        ],
      ),
      // --- NEW: Stack Layout for Animations ---
      body: Stack(
        children: [
          // 1. The Base Layer: The List of Containers
          Positioned.fill(
            child: ListView.builder(
              // Add padding to the bottom so the last item isn't hidden by the panel
              padding: const EdgeInsets.only(bottom: 100),
              itemCount: shadows.length,
              itemBuilder: (context, index) {
                final pair = shadows[index];
                return ShadowCard(
                  pair: pair,
                  onTap: () {
                    setState(() {
                      selectedShadowId = pair.id;
                      isPanelOpen = true; // Triggers panel sliding UP
                    });
                  },
                  onCopy: () {
                    copyShadowToClipboard(pair);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${pair.id} copied to clipboard!'),
                        behavior: SnackBarBehavior.floating,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // 2. The Custom Panel (Slides up from the bottom)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            left: 0,
            right: 0,
            // If open, it sits at the bottom (0). If closed, it hides below the screen (-400).
            bottom: isPanelOpen ? 0 : -400,
            child: selectedPair != null
                ? CustomPanel(
                    pair: selectedPair,
                    onClose: () {
                      setState(() {
                        isPanelOpen = false; // Triggers panel sliding DOWN
                      });
                    },
                  )
                : const SizedBox.shrink(),
          ),

          // 3. The Diamond Create Button (Slides down when panel opens)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            right: 30,
            // If panel is open, hide button below screen (-100). If closed, show it (30).
            bottom: isPanelOpen ? -100 : 30,
            child: GestureDetector(
              onTap: () {
                final newId =
                    'sh_${(shadows.length + 1).toString().padLeft(2, '0')}';
                ref.read(shadowProvider.notifier).addShadowPair(newId);
                setState(() {
                  selectedShadowId = newId;
                  isPanelOpen = true; // Open panel for the new shadow
                });
              },
              // --- THE CUSTOM DIAMOND SHAPE ---
              child: Transform.rotate(
                angle: 45 * 3.1415927 / 180, // Rotate square 45 degrees
                child: Container(
                  width: 55,
                  height: 55,
                  decoration: inset.BoxDecoration(
                    color: colors.slc, // Uses Secondary Layer Color
                    borderRadius: BorderRadius.circular(
                      12,
                    ), // Slightly rounded corners
                    boxShadow: [
                      // Dark outer shadow (Bottom Right)
                      inset.BoxShadow(
                        color: Colors.black.withOpacity(isDark ? 0.8 : 0.3),
                        blurRadius: 8,
                        offset: const Offset(4, 4),
                      ),
                      // Light inner shadow (Top Left)
                      inset.BoxShadow(
                        color: Colors.white.withOpacity(isDark ? 0.1 : 0.5),
                        blurRadius: 4,
                        offset: const Offset(-2, -2),
                        inset: true,
                      ),
                    ],
                  ),
                  child: Transform.rotate(
                    angle:
                        -45 *
                        3.1415927 /
                        180, // Rotate the icon BACK 45 degrees so it's upright
                    child: Icon(
                      Icons.add,
                      color: colors.bgc,
                      size: 28,
                    ), // Icon color is bgc
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
