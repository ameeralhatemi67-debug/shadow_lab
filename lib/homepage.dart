// lib/homepage.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_inset_shadow/flutter_inset_shadow.dart' as inset;

import 'providers/lab_provider.dart';
import 'providers/shadow_provider.dart';
import 'widgets/custom_panel.dart';
import 'widgets/home_views.dart';
import 'widgets/top_action_bar.dart'; // NEW: Extracted Action Bar
import 'widgets/labs_tray.dart'; // NEW: Extracted Labs Tray
import 'colortheme.dart';
import 'utils/color_logic.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  String? selectedShadowId;
  bool isPanelOpen = false;

  @override
  Widget build(BuildContext context) {
    // 1. Read Standard Riverpod State
    final labs = ref.watch(labProvider);
    final activeLabId = ref.watch(activeLabIdProvider);
    final viewMode = ref.watch(viewModeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultColors = Theme.of(context).extension<CustomColors>()!;
    final activeLab = labs.where((l) => l.id == activeLabId).firstOrNull;

    // 2. Read Mode-Isolated Global State
    final globalLightId = ref.watch(globalLightLabIdProvider);
    final globalDarkId = ref.watch(globalDarkLabIdProvider);

    // 3. Resolve Colors dynamically!
    final colors = ColorResolver.resolve(
      activeLab,
      labs, // Pass the entire list of workspaces
      globalLightId,
      globalDarkId,
      defaultColors,
      isDark,
    );

    final selectedPair = activeLab?.shadows
        .where((p) => p.id == selectedShadowId)
        .firstOrNull;

    return Scaffold(
      backgroundColor: colors.bgc,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // --- ROW 1: TOP ACTION BAR (Clean & Extracted) ---
                TopActionBar(colors: colors),

                // --- ROW 2: LABS TRAY & PIN (Clean & Extracted) ---
                LabsTray(
                  colors: colors,
                  onLabChanged: () {
                    // Triggers when you switch labs to ensure the editing panel closes securely
                    setState(() => isPanelOpen = false);
                  },
                ),

                // --- ROW 3: WORKSPACE CANVAS ---
                Expanded(
                  child: activeLab == null
                      ? Center(
                          child: Text(
                            "Create or select a Lab to begin",
                            style: TextStyle(
                              color: colors.mtext,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        )
                      : (viewMode == ViewMode.all
                            ? AllView(
                                activeLab: activeLab,
                                mTextColor: colors.mtext!,
                                onShadowSelected: (id) {
                                  setState(() {
                                    selectedShadowId = id;
                                    isPanelOpen = true;
                                  });
                                },
                              )
                            : FocusView(
                                activeLab: activeLab,
                                isDark: isDark,
                                cardColor: colors.blc!,
                                mTextColor: colors.mtext!,
                                sTextColor: colors.stext!,
                                selectedShadowId: selectedShadowId,
                                onShadowSelected: (id) {
                                  setState(() {
                                    selectedShadowId = id;
                                    isPanelOpen = true;
                                  });
                                },
                              )),
                ),
              ],
            ),

            // --- THE DIAMOND CREATE BUTTON ---
            if (activeLab != null)
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                right: 30,
                bottom: isPanelOpen ? -100 : 30,
                child: GestureDetector(
                  onTap: () {
                    final newName = "Token ${activeLab.shadows.length + 1}";
                    ref
                        .read(shadowControllerProvider)
                        .addShadowPair(activeLab.id, newName);

                    setState(() {
                      selectedShadowId = newName;
                      isPanelOpen = true;
                    });
                  },
                  child: Transform.rotate(
                    angle: 45 * 3.1415927 / 180,
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: inset.BoxDecoration(
                        color: colors.slc,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          inset.BoxShadow(
                            color: Colors.black.withOpacity(isDark ? 0.8 : 0.3),
                            blurRadius: 10,
                            offset: const Offset(5, 5),
                          ),
                          inset.BoxShadow(
                            color: Colors.white.withOpacity(isDark ? 0.1 : 0.5),
                            blurRadius: 5,
                            offset: const Offset(-2, -2),
                            inset: true,
                          ),
                        ],
                      ),
                      child: Transform.rotate(
                        angle: -45 * 3.1415927 / 180,
                        child: Icon(Icons.add, color: colors.bgc, size: 36),
                      ),
                    ),
                  ),
                ),
              ),

            // --- BOTTOM SHEET: CUSTOM PANEL ---
            if (selectedPair != null)
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                bottom: isPanelOpen ? 0 : -450,
                left: 0,
                right: 0,
                child: CustomPanel(
                  pair: selectedPair,
                  onClose: () {
                    setState(() {
                      isPanelOpen = false;
                    });
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
