// lib/widgets/shadow_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_inset_shadow/flutter_inset_shadow.dart' as inset;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/shadow_pair.dart';
import '../utils/trig_math.dart';
import '../colortheme.dart';
import '../providers/shadow_provider.dart';

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
    final colors = Theme.of(context).extension<CustomColors>()!;

    // Grab BOTH layers so we can render the dual-shadow effect
    final layer1 = isDark ? pair.dark : pair.light;
    final layer2 = isDark ? pair.dark2 : pair.light2;

    return GestureDetector(
      onTap: onTap, // Tapping the card selects it for the CustomPanel
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        height: 80,
        decoration: inset.BoxDecoration(
          color: colors.blc,
          borderRadius: BorderRadius.circular(16),
          // Note: Border removed as requested!
          boxShadow: [
            // --- SHADOW LAYER 1 ---
            if (layer1.isVisible) // NEW: Respect visibility toggle
              inset.BoxShadow(
                color: Color(layer1.colorValue),
                blurRadius: layer1.blur,
                spreadRadius: layer1.size, // FIX: The Size lever now works!
                offset: getOffsetFromAngle(layer1.angle, layer1.distance),
                inset: layer1.isInset,
              ),
            // --- SHADOW LAYER 2 ---
            if (layer2.isVisible) // NEW: Respect visibility toggle
              inset.BoxShadow(
                color: Color(layer2.colorValue),
                blurRadius: layer2.blur,
                spreadRadius: layer2.size, // FIX: The Size lever now works!
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
              // --- THE TEXT AREA ---
              // Wrapped in an Expanded and GestureDetector so tapping specifically here edits text
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => _showTextEditor(context, ref, colors),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pair.mainText,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: colors.mtext, // Uses Main Text Color
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        pair.subText,
                        style: TextStyle(
                          fontSize: 12, // Smaller Size
                          color: colors.stext, // Uses Secondary Text Color
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),

              // --- THE COPY BUTTON ---
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
                // Safely fire the global text update to Riverpod
                ref
                    .read(shadowProvider.notifier)
                    .updateText(
                      pair.id,
                      mainController.text.isEmpty ? " " : mainController.text,
                      subController.text.isEmpty ? " " : subController.text,
                    );
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
