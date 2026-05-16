// lib/widgets/top_action_bar.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import '../providers/lab_provider.dart';
import '../providers/shadow_provider.dart';
import '../colortheme.dart';
import '../utils/color_logic.dart';

class TopActionBar extends ConsumerWidget {
  final CustomColors colors;

  const TopActionBar({super.key, required this.colors});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeLabId = ref.watch(activeLabIdProvider);
    final viewMode = ref.watch(viewModeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                icon: Icon(
                  Icons.create_new_folder_outlined,
                  color: colors.mtext,
                  size: 28,
                ),
                tooltip: "Create New Lab",
                onPressed: () => _showCreateLabDialog(context, ref, colors),
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
          Row(
            children: [
              // (The old Global Toggle Icon was removed from here!)
              IconButton(
                icon: Icon(
                  Icons.palette_outlined,
                  color: colors.mtext,
                  size: 28,
                ),
                tooltip: "Workspace Colors",
                onPressed: activeLabId == null
                    ? null
                    : () => _showLabColorPicker(context),
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

  // =========================================================================
  // DIALOGS
  // =========================================================================

  void _showCreateLabDialog(
    BuildContext context,
    WidgetRef ref,
    CustomColors colors,
  ) {
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

  void _showLabColorPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Consumer(
          builder: (context, ref, child) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            final defaultColors = Theme.of(context).extension<CustomColors>()!;

            final allLabs = ref.watch(labProvider);
            final activeLabId = ref.watch(activeLabIdProvider);
            final activeLab = allLabs
                .where((l) => l.id == activeLabId)
                .firstOrNull;

            // --- NEW: Read the Mode-Isolated Global Trackers ---
            final globalLightId = ref.watch(globalLightLabIdProvider);
            final globalDarkId = ref.watch(globalDarkLabIdProvider);

            final liveColors = ColorResolver.resolve(
              activeLab,
              allLabs,
              globalLightId,
              globalDarkId,
              defaultColors,
              isDark,
            );

            if (activeLabId == null) return const SizedBox.shrink();

            // --- CHECK: Is THIS exact lab currently acting as the Global Profile? ---
            final isCurrentlyGlobal = isDark
                ? (globalDarkId == activeLabId)
                : (globalLightId == activeLabId);

            return AlertDialog(
              backgroundColor: defaultColors.bgc,
              title: Text(
                "Customize Workspace (${isDark ? 'Dark Mode' : 'Light Mode'})",
                style: TextStyle(color: liveColors.mtext),
              ),
              content: SingleChildScrollView(
                // Prevents pixel overflow since we added a new UI element
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // --- NEW: THE GLOBAL TOGGLE SWITCH ---
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        "Set as Global Profile",
                        style: TextStyle(
                          color: liveColors.mtext,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        "Apply this lab's colors to all workspaces in ${isDark ? 'Dark' : 'Light'} Mode.",
                        style: TextStyle(color: liveColors.stext, fontSize: 12),
                      ),
                      value: isCurrentlyGlobal,
                      activeColor: liveColors.slc,
                      onChanged: (bool value) {
                        // Flips the global switch for the CURRENT mode only!
                        if (isDark) {
                          ref
                              .read(globalDarkLabIdProvider.notifier)
                              .setGlobal(value ? activeLabId : null);
                        } else {
                          ref
                              .read(globalLightLabIdProvider.notifier)
                              .setGlobal(value ? activeLabId : null);
                        }
                      },
                    ),
                    Divider(color: liveColors.stext!.withOpacity(0.3)),
                    const SizedBox(height: 10),

                    // Color pickers edit activeLabId natively
                    _colorPickerRow(
                      context,
                      "Background",
                      liveColors.bgc!,
                      (c) => ref
                          .read(labProvider.notifier)
                          .updateWorkspaceColors(
                            activeLabId,
                            isDarkMode: isDark,
                            bg: c,
                          ),
                      liveColors,
                      defaultColors.bgc!,
                    ),
                    _colorPickerRow(
                      context,
                      "Card Color",
                      liveColors.blc!,
                      (c) => ref
                          .read(labProvider.notifier)
                          .updateWorkspaceColors(
                            activeLabId,
                            isDarkMode: isDark,
                            card: c,
                          ),
                      liveColors,
                      defaultColors.bgc!,
                    ),
                    _colorPickerRow(
                      context,
                      "Main Text",
                      liveColors.mtext!,
                      (c) => ref
                          .read(labProvider.notifier)
                          .updateWorkspaceColors(
                            activeLabId,
                            isDarkMode: isDark,
                            mText: c,
                          ),
                      liveColors,
                      defaultColors.bgc!,
                    ),
                    _colorPickerRow(
                      context,
                      "Secondary Text",
                      liveColors.stext!,
                      (c) => ref
                          .read(labProvider.notifier)
                          .updateWorkspaceColors(
                            activeLabId,
                            isDarkMode: isDark,
                            sText: c,
                          ),
                      liveColors,
                      defaultColors.bgc!,
                    ),
                    _colorPickerRow(
                      context,
                      "Action Button / Highlight",
                      liveColors.slc!,
                      (c) => ref
                          .read(labProvider.notifier)
                          .updateWorkspaceColors(
                            activeLabId,
                            isDarkMode: isDark,
                            slc: c,
                          ),
                      liveColors,
                      defaultColors.bgc!,
                    ),
                    const SizedBox(height: 20),
                    TextButton(
                      onPressed: () {
                        ref
                            .read(labProvider.notifier)
                            .resetWorkspaceColors(activeLabId, isDark);
                      },
                      child: const Text(
                        "Reset to Theme Defaults",
                        style: TextStyle(color: Colors.redAccent),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    "Done",
                    style: TextStyle(color: liveColors.mtext),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _colorPickerRow(
    BuildContext context,
    String label,
    Color currentColor,
    Function(int) onColorSelected,
    CustomColors liveColors,
    Color stableBgColor,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label, style: TextStyle(color: liveColors.mtext)),
      trailing: Icon(Icons.circle, color: currentColor, size: 28),
      onTap: () {
        Color tempColor = currentColor;
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: stableBgColor,
            title: Text(
              "Pick $label",
              style: TextStyle(color: liveColors.mtext),
            ),
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
                    color: liveColors.mtext,
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
