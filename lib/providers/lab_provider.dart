// lib/providers/lab_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:shadow_app/models/labs.dart';
import '../models/shadow_pair.dart'; // Needed for the updatedShadows list

// --- VIEW MODE STATE (All vs Focus) ---
enum ViewMode { all, focus }

class ViewModeNotifier extends Notifier<ViewMode> {
  @override
  ViewMode build() => ViewMode.all;

  void setMode(ViewMode mode) => state = mode;

  void toggle() =>
      state = state == ViewMode.all ? ViewMode.focus : ViewMode.all;
}

final viewModeProvider = NotifierProvider<ViewModeNotifier, ViewMode>(
  () => ViewModeNotifier(),
);

// --- ACTIVE LAB STATE ---
class ActiveLabNotifier extends Notifier<String?> {
  @override
  String? build() {
    // Automatically select the first lab on app startup if one exists
    final box = Hive.box<Lab>('labs_box');
    if (box.isNotEmpty) {
      final sortedLabs = box.values.toList()
        ..sort((a, b) => a.isPinned == b.isPinned ? 0 : (a.isPinned ? -1 : 1));
      return sortedLabs.first.id;
    }
    return null;
  }

  void setLab(String? labId) => state = labId;
}

final activeLabIdProvider = NotifierProvider<ActiveLabNotifier, String?>(
  () => ActiveLabNotifier(),
);

// --- THE MASTER LAB WORKSPACE PROVIDER ---
class LabListNotifier extends Notifier<List<Lab>> {
  late final Box<Lab> _box;

  @override
  List<Lab> build() {
    _box = Hive.box<Lab>('labs_box');

    // --- FIX 1: THE SMART DEFAULT LAB CHECK ---
    // Only ever runs if the user has 0 labs (like on a fresh install)
    if (_box.isEmpty) {
      final defaultLab = Lab(
        id: 'lab_${DateTime.now().millisecondsSinceEpoch}',
        name: 'Default Lab',
      );
      _box.put(defaultLab.id, defaultLab);
    }

    return _getSortedLabs();
  }

  // --- CRUD OPERATIONS ---
  void createLab(String name) {
    final newLab = Lab(
      id: 'lab_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
    );
    _box.put(newLab.id, newLab);
    state = _getSortedLabs();

    // Automatically switch to the newly created lab!
    ref.read(activeLabIdProvider.notifier).setLab(newLab.id);
  }

  void deleteLab(String labId) {
    _box.delete(labId);
    state = _getSortedLabs();
  }

  void togglePin(String labId) {
    final lab = _box.get(labId);
    if (lab != null) {
      final updated = lab.copyWith(isPinned: !lab.isPinned);
      _box.put(labId, updated);
      state = _getSortedLabs();
    }
  }

  void updateWorkspaceColors(
    String labId, {
    int? bg,
    int? card,
    int? mText,
    int? sText,
  }) {
    final lab = _box.get(labId);
    if (lab != null) {
      final updated = lab.copyWith(
        backgroundColor: bg,
        cardColor: card,
        mainTextColor: mText,
        subTextColor: sText,
      );
      _box.put(labId, updated);
      state = _getSortedLabs();
    }
  }

  Lab? getLabById(String id) => _box.get(id);

  void updateLabShadows(String labId, List<ShadowPair> updatedShadows) {
    final lab = _box.get(labId);
    if (lab != null) {
      _box.put(labId, lab.copyWith(shadows: updatedShadows));
      state = _getSortedLabs();
    }
  }

  List<Lab> _getSortedLabs() {
    final labs = _box.values.toList();
    labs.sort((a, b) => a.isPinned == b.isPinned ? 0 : (a.isPinned ? -1 : 1));
    return labs;
  }
}

final labProvider = NotifierProvider<LabListNotifier, List<Lab>>(
  () => LabListNotifier(),
);
