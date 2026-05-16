// lib/widgets/shadow_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_inset_shadow/flutter_inset_shadow.dart' as inset;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadow_app/providers/lab_provider.dart';
import '../models/shadow_pair.dart';
import '../utils/trig_math.dart';
import '../colortheme.dart';
import '../providers/shadow_provider.dart';
import '../utils/color_logic.dart';

class ShadowCard extends ConsumerWidget {
  final ShadowPair pair;
  final VoidCallback onCopy;
  final VoidCallback onTap;

  const ShadowCard({
    super.key,
    required this.pair,
    required this.onCopy,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // --- 1. Fetch Local Lab State ---
    final labs = ref.watch(labProvider);
    final activeLabId = ref.watch(activeLabIdProvider);
    final activeLab = labs.where((l) => l.id == activeLabId).firstOrNull;
    final defaultColors = Theme.of(context).extension<CustomColors>()!;

    // --- 2. Fetch Global Profile State ---
    final isGlobalEnabled = ref.watch(globalOverrideProvider);
    final globalProfile = ref.read(labProvider.notifier).getGlobalProfile();

    // --- 3. The Magic Resolver Line ---
    final colors = ColorResolver.resolve(
      activeLab,
      globalProfile,
      isGlobalEnabled,
      defaultColors,
      isDark,
    );

    // Grab BOTH layers so we can render the dual-shadow effect
    final layer1 = isDark ? pair.dark : pair.light;
    final layer2 = isDark ? pair.dark2 : pair.light2;

    // --- 1. THE OUTER WRAPPER (Catches all empty space taps for Shadow Edit) ---
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap, // Opens the CustomPanel
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        height: 80,
        decoration: inset.BoxDecoration(
          color: colors.blc, // Now uses the dynamic card color!
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            if (layer1.isVisible)
              inset.BoxShadow(
                color: Color(layer1.colorValue),
                blurRadius: layer1.blur,
                spreadRadius: layer1.size,
                offset: getOffsetFromAngle(layer1.angle, layer1.distance),
                inset: layer1.isInset,
              ),
            if (layer2.isVisible)
              inset.BoxShadow(
                color: Color(layer2.colorValue),
                blurRadius: layer2.blur,
                spreadRadius: layer2.size,
                offset: getOffsetFromAngle(layer2.angle, layer2.distance),
                inset: layer2.isInset,
              ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // --- 2. THE DYNAMIC TEXT WRAPPER (Left) ---
              Flexible(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => _showTextEditor(
                    context,
                    ref,
                    colors,
                  ), // Opens Text Editor
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize:
                        MainAxisSize.min, // Shrinks vertically to text height
                    children: [
                      Text(
                        pair.mainText,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: colors
                              .mtext, // Now uses the dynamic main text color!
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        pair.subText,
                        style: TextStyle(
                          fontSize: 12,
                          color: colors
                              .stext, // Now uses the dynamic sub text color!
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),

              // --- 3. THE COPY BUTTON (Right) ---
              IconButton(
                icon: Icon(Icons.copy_all, color: colors.mtext),
                onPressed: onCopy,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- THE TEXT EDITOR DIALOG ---
  void _showTextEditor(
    BuildContext context,
    WidgetRef ref,
    CustomColors colors,
  ) {
    // Pre-fill the text fields with the current words
    final mainController = TextEditingController(text: pair.mainText);
    final subController = TextEditingController(text: pair.subText);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: colors.bgc,
          title: Text(
            'Edit Container Text',
            style: TextStyle(color: colors.mtext),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: mainController,
                style: TextStyle(color: colors.mtext),
                decoration: InputDecoration(
                  labelText: 'Main Text',
                  labelStyle: TextStyle(color: colors.stext),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: colors.stext!.withOpacity(0.5),
                    ),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: colors.mtext!),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: subController,
                style: TextStyle(color: colors.mtext),
                decoration: InputDecoration(
                  labelText: 'Secondary Text',
                  labelStyle: TextStyle(color: colors.stext),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: colors.stext!.withOpacity(0.5),
                    ),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: colors.mtext!),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: colors.stext)),
            ),
            TextButton(
              onPressed: () {
                // Get the current folder
                final labId = ref.read(activeLabIdProvider);
                if (labId != null) {
                  // Fire the text update to the specific Lab
                  ref
                      .read(shadowControllerProvider)
                      .updateText(
                        labId,
                        pair.id,
                        mainController.text.isEmpty ? " " : mainController.text,
                        subController.text.isEmpty ? " " : subController.text,
                      );
                }
                Navigator.pop(context);
              },
              child: Text(
                'Save',
                style: TextStyle(
                  color: colors.mtext,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
