// lib/widgets/custom_panel.dart
import 'dart:ui'; // NEW: Required for the background blur effect
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../models/shadow_pair.dart';
import '../providers/shadow_provider.dart';
import '../colortheme.dart';

class CustomPanel extends ConsumerStatefulWidget {
  final ShadowPair pair;
  final VoidCallback onClose;

  const CustomPanel({super.key, required this.pair, required this.onClose});

  @override
  ConsumerState<CustomPanel> createState() => _CustomPanelState();
}

class _CustomPanelState extends ConsumerState<CustomPanel> {
  // Tracks which layer is currently selected for the sliders to edit
  int activeLayerIndex = 1;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = Theme.of(context).extension<CustomColors>()!;

    // Get both layers
    final layer1 = isDark ? widget.pair.dark : widget.pair.light;
    final layer2 = isDark ? widget.pair.dark2 : widget.pair.light2;

    // The layer currently controlled by the sliders
    final activeSettings = activeLayerIndex == 1 ? layer1 : layer2;

    return GestureDetector(
      onVerticalDragEnd: (details) {
        if (details.primaryVelocity! > 100) {
          widget.onClose();
        }
      },
      child: Container(
        height: 350,
        decoration: BoxDecoration(
          color: colors.blc,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // The Drag Pill
            Padding(
              padding: const EdgeInsets.only(top: 12.0, bottom: 8.0),
              child: Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: colors.stext!.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  // --------------------------------------------------------
                  // TOP ROW (85%): The Split Control Area
                  // --------------------------------------------------------
                  Expanded(
                    flex: 85,
                    child: Row(
                      children: [
                        // --- LEFT COLUMN (40%) ---
                        Expanded(
                          flex: 40,
                          child: Padding(
                            padding: const EdgeInsets.only(
                              left: 20.0,
                              top: 10,
                              bottom: 10,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Row 1: Link Icon AND Info Icon
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        widget.pair.isLinked
                                            ? Icons.link
                                            : Icons.link_off,
                                      ),
                                      color: widget.pair.isLinked
                                          ? colors.mtext
                                          : colors.stext,
                                      tooltip: widget.pair.isLinked
                                          ? 'Linked'
                                          : 'Unlinked',
                                      onPressed: () {
                                        if (!widget.pair.isLinked) {
                                          ref
                                              .read(shadowProvider.notifier)
                                              .reLink(widget.pair.id, !isDark);
                                        }
                                      },
                                    ),
                                    // --- NEW: Info Button ---
                                    IconButton(
                                      icon: Icon(
                                        Icons.info_outline,
                                        color: colors.mtext,
                                      ),
                                      tooltip: 'Information',
                                      onPressed: () =>
                                          _showInfoDialog(context, colors),
                                    ),
                                  ],
                                ),
                                // Row 2: Square 1 + Invert
                                _buildLayerRow(1, layer1, colors, isDark),
                                // Row 3: Square 2 + Invert
                                _buildLayerRow(2, layer2, colors, isDark),
                              ],
                            ),
                          ),
                        ),

                        // --- RIGHT COLUMN (60%) ---
                        Expanded(
                          flex: 60,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildVerticalSlider(
                                  "Size",
                                  activeSettings.size,
                                  -50,
                                  50,
                                  colors,
                                  (v) {
                                    _updateSetting(
                                      ref,
                                      activeSettings.copyWith(size: v),
                                      isDark,
                                      activeLayerIndex,
                                    );
                                  },
                                ),
                                _buildVerticalSlider(
                                  "Des",
                                  activeSettings.distance,
                                  0,
                                  50,
                                  colors,
                                  (v) {
                                    _updateSetting(
                                      ref,
                                      activeSettings.copyWith(distance: v),
                                      isDark,
                                      activeLayerIndex,
                                    );
                                  },
                                ),
                                _buildVerticalSlider(
                                  "Angle",
                                  activeSettings.angle,
                                  0,
                                  360,
                                  colors,
                                  (v) {
                                    _updateSetting(
                                      ref,
                                      activeSettings.copyWith(angle: v),
                                      isDark,
                                      activeLayerIndex,
                                    );
                                  },
                                ),
                                _buildVerticalSlider(
                                  "Blur",
                                  activeSettings.blur,
                                  0,
                                  100,
                                  colors,
                                  (v) {
                                    _updateSetting(
                                      ref,
                                      activeSettings.copyWith(blur: v),
                                      isDark,
                                      activeLayerIndex,
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // --------------------------------------------------------
                  // BOTTOM ROW (15%): The Save Area
                  // --------------------------------------------------------
                  Expanded(
                    flex: 15,
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            color: colors.stext!.withOpacity(0.2),
                          ),
                        ),
                      ),
                      child: InkWell(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Auto-saved to ${widget.pair.id}'),
                              duration: const Duration(seconds: 1),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                          widget.onClose();
                        },
                        child: Center(
                          child: Text(
                            "Save",
                            style: TextStyle(
                              color: colors.mtext,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET BUILDERS & LOGIC ---

  Widget _buildLayerRow(
    int layerIndex,
    ShadowSettings settings,
    CustomColors colors,
    bool isDark,
  ) {
    bool isActive = activeLayerIndex == layerIndex;

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        // --- NEW: Visibility Toggle & Square ---
        GestureDetector(
          onTap: () {
            if (activeLayerIndex == layerIndex) {
              // If it's ALREADY active, tap toggles the visibility
              _updateSetting(
                ref,
                settings.copyWith(isVisible: !settings.isVisible),
                isDark,
                layerIndex,
              );
            } else {
              // If it's not active, tap simply selects it so sliders can edit it
              setState(() => activeLayerIndex = layerIndex);
            }
          },
          onLongPress: () => _showColorPicker(
            context,
            ref,
            colors,
            settings,
            isDark,
            layerIndex,
          ),
          child: Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: Color(settings.colorValue),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isActive
                    ? colors.mtext!
                    : colors.stext!.withOpacity(0.3),
                width: isActive ? 2.5 : 1,
              ),
            ),
            // The hidden icon
            child: settings.isVisible
                ? null
                : Icon(Icons.visibility_off, color: colors.bgc),
          ),
        ),
        const SizedBox(width: 15),

        IconButton(
          icon: Icon(
            settings.isInset ? Icons.flip_to_back : Icons.flip_to_front,
          ),
          color: settings.isInset ? colors.mtext : colors.stext,
          tooltip: settings.isInset ? 'Inner Shadow' : 'Outer Shadow',
          onPressed: () {
            _updateSetting(
              ref,
              settings.copyWith(isInset: !settings.isInset),
              isDark,
              layerIndex,
            );
          },
        ),
      ],
    );
  }

  Widget _buildVerticalSlider(
    String label,
    double value,
    double min,
    double max,
    CustomColors colors,
    ValueChanged<double> onChanged,
  ) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: colors.mtext,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: RotatedBox(
            quarterTurns: 3,
            child: Slider(
              value: value,
              min: min,
              max: max,
              activeColor: colors.mtext,
              inactiveColor: colors.stext?.withOpacity(0.3),
              thumbColor: colors.mtext,
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  void _updateSetting(
    WidgetRef ref,
    ShadowSettings newSettings,
    bool isDark,
    int layerIndex,
  ) {
    ref
        .read(shadowProvider.notifier)
        .updateShadow(widget.pair.id, !isDark, layerIndex, newSettings);
  }

  void _showColorPicker(
    BuildContext context,
    WidgetRef ref,
    CustomColors colors,
    ShadowSettings activeSettings,
    bool isDark,
    int layerIndex,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        Color tempColor = Color(activeSettings.colorValue);
        return AlertDialog(
          title: Text(
            'Pick Shadow Color',
            style: TextStyle(color: colors.mtext),
          ),
          backgroundColor: colors.bgc,
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: tempColor,
              onColorChanged: (color) => tempColor = color,
              pickerAreaHeightPercent: 0.8,
              enableAlpha: true,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                _updateSetting(
                  ref,
                  activeSettings.copyWith(colorValue: tempColor.value),
                  isDark,
                  layerIndex,
                );
                Navigator.of(context).pop();
              },
              child: Text('Done', style: TextStyle(color: colors.mtext)),
            ),
          ],
        );
      },
    );
  }

  // --- NEW: Info Dialog Builder ---
  void _showInfoDialog(BuildContext context, CustomColors colors) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(
        0.4,
      ), // Darkens the background slightly
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 5,
            sigmaY: 5,
          ), // Blurs the background
          child: Dialog(
            backgroundColor: colors.bgc,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "How it works",
                        style: TextStyle(
                          color: colors.mtext,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: colors.mtext),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 10),
                  _buildInfoRow(
                    "Size",
                    "Expands or shrinks the shadow. Use negative values to tuck it under the container.",
                    colors,
                  ),
                  _buildInfoRow(
                    "Des",
                    "Distance. Moves the shadow away from the center based on the Angle.",
                    colors,
                  ),
                  _buildInfoRow(
                    "Angle",
                    "The directional angle (0-360°) the shadow is cast towards.",
                    colors,
                  ),
                  _buildInfoRow(
                    "Blur",
                    "Softens the edges. Higher values create a wider, softer glow.",
                    colors,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String title, String desc, CustomColors colors) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 50,
            child: Text(
              title,
              style: TextStyle(
                color: colors.mtext,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(
              desc,
              style: TextStyle(color: colors.stext, height: 1.3),
            ),
          ),
        ],
      ),
    );
  }
}
