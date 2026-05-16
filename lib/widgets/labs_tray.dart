// lib/widgets/labs_tray.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/lab_provider.dart';
import '../colortheme.dart';

class LabsTray extends ConsumerWidget {
  final CustomColors colors;
  final VoidCallback onLabChanged;

  const LabsTray({super.key, required this.colors, required this.onLabChanged});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Read the states directly inside this widget
    final labs = ref.watch(labProvider);
    final activeLabId = ref.watch(activeLabIdProvider);
    final activeLab = labs.where((l) => l.id == activeLabId).firstOrNull;

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
                    onLabChanged(); // Tells homepage to close the editing panel
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
}
