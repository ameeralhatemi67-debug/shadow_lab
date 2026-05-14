// lib/homepage.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:shadow_app/providers/shadow_provider.dart';
import 'package:flutter_inset_shadow/flutter_inset_shadow.dart' as inset;

import 'providers/lab_provider.dart';
import 'widgets/custom_panel.dart';
import 'widgets/home_views.dart'; // Imports your newly extracted views!
import 'colortheme.dart';
import 'utils/color_logic.dart'; // Imports the brilliant color fallback logic

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
    // 1. Read Riverpod State
    final labs = ref.watch(labProvider);
    final activeLabId = ref.watch(activeLabIdProvider);
    final viewMode = ref.watch(viewModeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultColors = Theme.of(context).extension<CustomColors>()!;

    // 2. Identify Active Lab
    final activeLab = labs.where((l) => l.id == activeLabId).firstOrNull;

    // 3. Resolve Colors dynamically using our new utility!
    // This perfectly calculates if we should use Lab custom colors or Global Theme colors.
    final colors = ColorResolver.resolve(activeLab, defaultColors);

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
                // --- ROW 1: TOP ACTION BAR ---
                _buildActionBar(
                  activeLabId,
                  activeLab,
                  viewMode,
                  isDark,
                  colors,
                ),

                // --- ROW 2: LABS TRAY & PIN ---
                _buildLabsTray(labs, activeLabId, activeLab, colors),

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
                            // Calls the code from home_views.dart
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
                            // Calls the code from home_views.dart
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
            // Only show it if a Lab is active and we are in Default (All) mode
            if (activeLab != null)
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                right: 30,
                // If panel is open, hide button below screen. If closed, show it.
                bottom: isPanelOpen ? -100 : 30,
                child: GestureDetector(
                  onTap: () {
                    final newName = "Token ${activeLab.shadows.length + 1}";
                    // Safely asks the controller to do the math and save it to the current folder
                    ref
                        .read(shadowControllerProvider)
                        .addShadowPair(activeLab.id, newName);

                    setState(() {
                      selectedShadowId = newName;
                      isPanelOpen = true; // Open panel for the new shadow
                    });
                  },
                  child: Transform.rotate(
                    angle: 45 * 3.1415927 / 180, // Rotate square 45 degrees
                    child: Container(
                      width: 70, // <-- MADE BIGGER
                      height: 70, // <-- MADE BIGGER
                      decoration: inset.BoxDecoration(
                        color: colors.slc, // Uses Secondary Layer Color
                        borderRadius: BorderRadius.circular(
                          16,
                        ), // Slightly rounder for the larger size
                        boxShadow: [
                          // Dark outer shadow
                          inset.BoxShadow(
                            color: Colors.black.withOpacity(isDark ? 0.8 : 0.3),
                            blurRadius: 10,
                            offset: const Offset(5, 5),
                          ),
                          // Light inner shadow
                          inset.BoxShadow(
                            color: Colors.white.withOpacity(isDark ? 0.1 : 0.5),
                            blurRadius: 5,
                            offset: const Offset(-2, -2),
                            inset: true,
                          ),
                        ],
                      ),
                      child: Transform.rotate(
                        angle:
                            -45 *
                            3.1415927 /
                            180, // Rotate the icon BACK upright
                        child: Icon(
                          Icons.add,
                          color: colors.bgc,
                          size: 36, // <-- MADE BIGGER
                        ),
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

  // =========================================================================
  // UI BUILDERS FOR TOP BARS
  // =========================================================================

  Widget _buildActionBar(
    String? activeLabId,
    dynamic activeLab,
    ViewMode viewMode,
    bool isDark,
    CustomColors colors,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // LEFT: [+] Create Lab, Toggle View
          Row(
            children: [
              IconButton(
                icon: Icon(
                  Icons.create_new_folder_outlined,
                  color: colors.mtext,
                  size: 28,
                ),
                tooltip: "Create New Lab",
                onPressed: () => _showCreateLabDialog(context, colors),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(
                  viewMode == ViewMode.all
                      ? Icons.view_carousel_outlined
                      : Icons.view_agenda_outlined,
                  color: colors.mtext,
                  size: 28,
                ),
                tooltip: "Toggle View Mode",
                onPressed: () => ref.read(viewModeProvider.notifier).toggle(),
              ),
            ],
          ),
          // RIGHT: Palette Colors, Theme Toggle
          Row(
            children: [
              IconButton(
                icon: Icon(
                  Icons.palette_outlined,
                  color: colors.mtext,
                  size: 28,
                ),
                tooltip: "Lab Colors",
                onPressed: activeLabId == null
                    ? null
                    : () => _showLabColorPicker(
                        context,
                        activeLabId,
                        activeLab,
                        colors,
                      ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(
                  isDark ? Icons.light_mode : Icons.dark_mode,
                  color: colors.mtext,
                  size: 28,
                ),
                tooltip: "Toggle Theme",
                onPressed: () =>
                    ref.read(themeModeProvider.notifier).toggleTheme(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLabsTray(
    List<dynamic> labs,
    String? activeLabId,
    dynamic activeLab,
    CustomColors colors,
  ) {
    return Container(
      height: 45,
      margin: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: labs.length,
              itemBuilder: (context, index) {
                final lab = labs[index];
                final isSelected = lab.id == activeLabId;
                return GestureDetector(
                  onTap: () {
                    setState(() => isPanelOpen = false);
                    ref.read(activeLabIdProvider.notifier).setLab(lab.id);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    decoration: BoxDecoration(
                      color: isSelected ? colors.slc : Colors.transparent,
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: isSelected
                            ? Colors.transparent
                            : colors.stext!.withOpacity(0.3),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      lab.name,
                      style: TextStyle(
                        color: isSelected ? colors.bgc : colors.mtext,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0, left: 8.0),
            child: IconButton(
              icon: Icon(
                activeLab?.isPinned == true
                    ? Icons.push_pin
                    : Icons.push_pin_outlined,
                color: colors.mtext,
              ),
              tooltip: "Pin Lab",
              onPressed: activeLabId == null
                  ? null
                  : () => ref.read(labProvider.notifier).togglePin(activeLabId),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // DIALOGS
  // =========================================================================

  void _showCreateLabDialog(BuildContext context, CustomColors colors) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colors.bgc,
        title: Text("Create New Lab", style: TextStyle(color: colors.mtext)),
        content: TextField(
          controller: controller,
          style: TextStyle(color: colors.mtext),
          decoration: InputDecoration(
            hintText: "Lab Name",
            hintStyle: TextStyle(color: colors.stext),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: colors.stext!),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: colors.mtext!),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel", style: TextStyle(color: colors.stext)),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                ref.read(labProvider.notifier).createLab(controller.text);
              }
              Navigator.pop(context);
            },
            child: Text(
              "Create",
              style: TextStyle(
                color: colors.mtext,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLabColorPicker(
    BuildContext context,
    String labId,
    dynamic activeLab,
    CustomColors colors,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: colors.bgc,
          title: Text(
            "Customize Workspace",
            style: TextStyle(color: colors.mtext),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _colorPickerRow(
                "Background",
                colors.bgc!,
                (c) => ref
                    .read(labProvider.notifier)
                    .updateWorkspaceColors(labId, bg: c),
                colors,
              ),
              _colorPickerRow(
                "Card Color",
                colors.blc!,
                (c) => ref
                    .read(labProvider.notifier)
                    .updateWorkspaceColors(labId, card: c),
                colors,
              ),
              _colorPickerRow(
                "Main Text",
                colors.mtext!,
                (c) => ref
                    .read(labProvider.notifier)
                    .updateWorkspaceColors(labId, mText: c),
                colors,
              ),
              _colorPickerRow(
                "Secondary Text",
                colors.stext!,
                (c) => ref
                    .read(labProvider.notifier)
                    .updateWorkspaceColors(labId, sText: c),
                colors,
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  ref
                      .read(labProvider.notifier)
                      .updateWorkspaceColors(
                        labId,
                        bg: null,
                        card: null,
                        mText: null,
                        sText: null,
                      );
                  Navigator.pop(context);
                },
                child: const Text(
                  "Reset to Theme Defaults",
                  style: TextStyle(color: Colors.redAccent),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Done", style: TextStyle(color: colors.mtext)),
            ),
          ],
        );
      },
    );
  }

  Widget _colorPickerRow(
    String label,
    Color currentColor,
    Function(int) onColorSelected,
    CustomColors colors,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label, style: TextStyle(color: colors.mtext)),
      trailing: Icon(Icons.circle, color: currentColor, size: 28),
      onTap: () {
        Color tempColor = currentColor;
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: colors.bgc,
            title: Text("Pick $label", style: TextStyle(color: colors.mtext)),
            content: SingleChildScrollView(
              child: ColorPicker(
                pickerColor: tempColor,
                onColorChanged: (c) => tempColor = c,
                enableAlpha: false,
                pickerAreaHeightPercent: 0.7,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  onColorSelected(tempColor.value);
                  Navigator.pop(ctx);
                },
                child: Text(
                  "Select",
                  style: TextStyle(
                    color: colors.mtext,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
