// lib/widgets/home_views.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadow_app/models/labs.dart';
import 'package:shadow_app/widgets/shadow_card.dart';
import 'package:flutter/services.dart'; // Required for copying to clipboard
import '../utils/export_templates.dart'; // Your code generator!

// =========================================================================
// VIEW 1: THE LIST (ALL VIEW / DEFAULT)
// =========================================================================
class AllView extends ConsumerWidget {
  final Lab activeLab;
  final Color mTextColor;
  final Function(String) onShadowSelected;

  const AllView({
    super.key,
    required this.activeLab,
    required this.mTextColor,
    required this.onShadowSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 120),
      itemCount: activeLab.shadows.length,
      itemBuilder: (context, index) {
        // --- THE SHADOW CARDS ---
        final pair = activeLab.shadows[index];
        return ShadowCard(
          pair: pair,
          onCopy: () async {
            // 1. Generate the Flutter/CSS code using your template
            // (Make sure this matches the exact class/method name in your export_templates.dart)

            final generatedCode = ExportTemplates.generateFlutterCode(pair);
            await Clipboard.setData(ClipboardData(text: generatedCode));

            // 3. Show a quick visual confirmation to the user
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Shadow code copied to clipboard!'),
                  backgroundColor: mTextColor, // Uses your custom UI colors
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          },

          onTap: () => onShadowSelected(pair.id),
        );
      },
    );
  }
}

// =========================================================================
// VIEW 2: THE SWIPER (LIST VIEW)
// =========================================================================
class FocusView extends StatefulWidget {
  final Lab activeLab;
  final bool isDark;
  final Color cardColor;
  final Color mTextColor;
  final Color sTextColor;
  final Function(String) onShadowSelected;
  final String?
  selectedShadowId; // <--- NEW: Tells the swiper which card is active

  const FocusView({
    super.key,
    required this.activeLab,
    required this.isDark,
    required this.cardColor,
    required this.mTextColor,
    required this.sTextColor,
    required this.onShadowSelected,
    this.selectedShadowId, // <--- NEW
  });

  @override
  State<FocusView> createState() => _FocusViewState();
}

class _FocusViewState extends State<FocusView> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    // Start the swiper on the currently selected card (if one is open)
    int initialPage = 0;
    if (widget.selectedShadowId != null) {
      initialPage = widget.activeLab.shadows.indexWhere(
        (s) => s.id == widget.selectedShadowId,
      );
      if (initialPage == -1) initialPage = 0;
    }
    _pageController = PageController(initialPage: initialPage);
  }

  @override
  void didUpdateWidget(FocusView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // THE MAGIC: If a new card was just created (or selected), swipe to it automatically!
    if (widget.selectedShadowId != oldWidget.selectedShadowId &&
        widget.selectedShadowId != null) {
      final newIndex = widget.activeLab.shadows.indexWhere(
        (s) => s.id == widget.selectedShadowId,
      );
      if (newIndex != -1 && _pageController.hasClients) {
        // PostFrameCallback ensures the new page exists before we try to swipe to it
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_pageController.hasClients) {
            _pageController.animateToPage(
              newIndex,
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
            );
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.activeLab.shadows.isEmpty) {
      return Center(
        child: Text(
          "Add a shadow in Default mode first.",
          style: TextStyle(color: widget.mTextColor),
        ),
      );
    }

    // The horizontal swiper
    return PageView.builder(
      controller: _pageController, // <--- Attached the controller here!
      itemCount: widget.activeLab.shadows.length,
      itemBuilder: (context, index) {
        final pair = widget.activeLab.shadows[index];

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 10.0, bottom: 5.0),
              child: Text(
                pair.id,
                style: TextStyle(
                  color: widget.mTextColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(bottom: 120),
                itemCount: 8,
                itemBuilder: (context, i) {
                  return ShadowCard(
                    pair: pair,
                    onCopy: () {},
                    onTap: () => widget.onShadowSelected(pair.id),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
